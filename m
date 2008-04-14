From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 12:29:26 +0200
Message-ID: <87ve2kviex.fsf@basil.nowhere.org>
References: <47FEADCB.7070104@rtr.ca>
	<22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc>
	<200804132040.12138.rjw@sisk.pl> <20080413184730.GD8474@1wt.eu>
	<20080413121831.d89dd424.akpm@linux-foundation.org>
	<20080414101813.GB14549@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757028AbYDNKbk@vger.kernel.org>
In-Reply-To: <20080414101813.GB14549@elte.hu> (Ingo Molnar's message of "Mon, 14 Apr 2008 12:18:13 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar <mingo@elte.hu> writes:
>
> doing _kernel_ bisection is totally hard at the moment - it disrupts the 
> user way too much and causes many hours of work for most users. 

It depends. Sometimes the bisection can be done in qemu/kvm/xen or
similar tools.  At least if the problem is not too hardware
dependent. And more and more people actually run in such environments.

I can also do it faster with autoboot or nfs root/powerswitch, but 
admittedly that's a very specialized setup most people don't have.

Still I agree with your basic point that it should be only
last resort.

-Andi
