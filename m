From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive
 vsnprintf
Date: Sat, 6 Mar 2010 14:03:02 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain> <1267911399.849.39.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267911399.849.39.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 6 Mar 2010, Joe Perches wrote:
> 
> Is that an ack, a nack or a get the hell out?

It's mostly an Ack. I think the concept is great. I'd love to have some 
way to limit recursion, and I'd also love to see some actual numbers of 
how deep the vsnprintf stack frame is, but I don't see how to do the 
first, and I'm hoping the second isn't too horrible.

		Linus
