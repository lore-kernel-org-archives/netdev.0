From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 08:39:08 -0700 (PDT)
Message-ID: <20080424.083908.147395158.davem@davemloft.net>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, drepper@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760973AbYDXPj2@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.10.0804240828100.2779@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Apr 2008 08:29:14 -0700 (PDT)

> 
> 
> On Thu, 24 Apr 2008, Alan Cox wrote:
> > 
> > Given we will never have 2^32 socket types, and in a sense this is part
> > of the type why not just use
> > 
> > 	socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, ...)
> 
> Ok, I have to admit that I find this very appealing. It looks much 
> cleaner, but perhaps more importantly, it also looks both readable _and_ 
> easier to use for the user-space programmer.

Me too.
