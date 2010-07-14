From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Wed, 14 Jul 2010 02:56:18 -0400
Message-ID: <20100714025618.181eacc5.billfink@mindspring.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	<AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
	<1279032023.2634.384.camel@edumazet-laptop>
	<AANLkTilrIByt4xAHhsBsKo3nDfv0_c3sF-dCiTiYiPnu@mail.gmail.com>
	<1279036193.2634.468.camel@edumazet-laptop>
	<AANLkTilgxvDPpBJvwbw3PHZfXDaa2_6-TbJ8lujz5y3V@mail.gmail.com>
	<1279077678.2444.95.camel@edumazet-laptop>
	<AANLkTikkcaionMp3SJLgo3JmCjxQ7rPZv3-3_RbxCx_4@mail.gmail.com>
	<1279078985.2444.105.camel@edumazet-laptop>
	<AANLkTikmuK0iWDjmG6lVgPyoZAHQ7ZdJmQobVrAQmgNh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Avi Kivity <avi@redhat.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Felipe W Damasio <felipewd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikmuK0iWDjmG6lVgPyoZAHQ7ZdJmQobVrAQmgNh@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jul 2010, Felipe W Damasio wrote:

> Hi,
> 
> 2010/7/14 Eric Dumazet <eric.dumazet@gmail.com>:
> >> I can, but my bosses will kick my ass if I bring down the ISP again :)
> >
> > I have no guarantee at all, even if we find the bug.
> 
> Ok :-)
> 
> >> If you think it's the only way to find the problem I'll tell them that
> >> I need to do it. In this case, please tell me what other config
> >> options/tools I can use to get as much info as possible...since I'll
> >> probably be able to test this only once more on the production
> >> environment for debugging purposes.
> >
> > You really should try to setup a lab to trigger the bug, and not doing
> > experiments on production :)
> 
> Right, I'm trying.
> 
> The thing is: The ISP is a 200Mbps network with 10,000 users. The
> first time it took around 2 minutes to trigger the bug. The second
> time it took around 17 minutes.
> 
> So I *think* it's some TCP flag with some weird content...but I can't
> find out what it is so I can trigger it on the lab.
> 
> So my only guess is to enable every possible debug flag I can think of
> to track the bug down on the production environment. Any hints here
> would be appreciated :)

Is it possible for you to mirror the production traffic to another
port, and then do a tcpdump capture to a series of files, so that
you might possibly be able to correlate the kernel crash to the
actual packets on the wire (and the Invalid Request squid errors)?
Just a suggestion.

						-Bill
