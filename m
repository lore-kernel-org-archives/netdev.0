From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Re[2]: do_IRQ: stack overflow: 872..
Date: Sat, 18 Dec 2004 17:46:20 +0100
Message-ID: <1103388380.3557.15.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1103368330.3566.15.camel@localhost.localdomain>
	 <20041218111420.GE338@wotan.suse.de>
	 <1103370690.3566.33.camel@localhost.localdomain>
	 <20041218135320.GA10030@wotan.suse.de>  <1421293830.20041218190742@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261190AbULRQn0@vger.kernel.org>
To: Crazy AMD K7 <snort2004@mail.ru>
In-Reply-To: <1421293830.20041218190742@mail.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op za, 18-12-2004 te 19:07 +0300, schreef Crazy AMD K7:
> > Note to the original poster: when you report a bug with a patched
> > kernel always mention it.
> I have mentioned earlier and Bart knows it.
> 
> I use 2.4.28
> + ebtables-brnf-8_vs_2.4.28.diff
> + U32 patch from patch-o-matic-ng-20040621.tar.bz2
> + patch for br_netfilter.c made by Bart to find out why kernel panic happens(it was a few
>   letters ago)
>   All patches has applies cleanly.
>   U32 doesn't affect on br_netfilter.c

Sorry, I don't know the ip_queue mechanism and I don't know what could
possibly go wrong.
All we know is that you no longer have kernel panics with the simple
patch I gave you (which just drops packets when a kernel panic would
happen otherwise, and tells about this with a printk). However, you
state there are no entries in your syslog that tell about this dropping.
Is your syslog working right? Do you have a console open on which kernel
messages get printed?

I still secretly suspect the snort code of inserting packets back into
the kernel that don't have an output device (I don't know if that's
possible, though).

cheers,
Bart
