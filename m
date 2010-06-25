From: Tom Herbert <therbert@google.com>
Subject: Re: SO_REUSEPORT
Date: Fri, 25 Jun 2010 10:39:26 -0700
Message-ID: <AANLkTikKKoS6YPWmIuNAdFIOhXi6d3qIf-Nsci3UaCGN@mail.gmail.com>
References: <AANLkTimxGK93hnV9-jGZAeeJ_JnrWCTaq-dkDvfUW6St@mail.gmail.com>
	<06r8f7-jsn.ln1@chipmunk.wormnet.eu>
	<4C2231B5.10401@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Clouter <alex@digriz.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C2231B5.10401@athenacr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Of course this depends on what you are doing, but my opinion is that the
>> functionality has been unneeded so far by people in the kernel, so *I*
>> must be doing something wrong ;)
>
> Tom Herbert gave a pretty great description of why you
> might want this functionality in his original patch submission:
>
> http://kerneltrap.org/mailarchive/linux-netdev/2010/4/19/6274993
>
> If you follow that thread though, there wasn't consensus about
> the best architecture & API for it, and nothing has made it
> yet.
>
I am planning to get back to this as the patch still needs some work
and isn't quite robust or optimized yet.  Some restructuring is needed
in the socket hash lists.  The UDP implementation in the patch will
work okay, and the TCP works as long as the number of listeners isn't
changing.
