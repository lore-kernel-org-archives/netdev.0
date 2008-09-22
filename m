From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Mon, 22 Sep 2008 06:53:39 +0000
Message-ID: <20080922065339.GA4399@ff.dom.local>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:58920 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbYIVGxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 02:53:48 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1262592fgg.17
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 23:53:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D7385D.40107@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 10:17:01AM +0400, Badalian Vyacheslav wrote:
> Jarek Poplawski:
> 
> Hello!
> There all requested information.
> I try 2.6.26.5 and again get:
> [143784.513166] CPU 2: Bank 0: 3200004000000800
> [143784.513241] CPU 2: Bank 5: 3200121020080400
> [143784.513241] Kernel panic - not syncing: CPU context corrupt
> [143784.513282] Rebooting in 3 seconds..

Hi,

Actually, I suggested you to read this Machine Check Exception help,
because I think you should first try to test your hardware instead of
sending configs. This type of error isn't usually seen with netdev
bugs.

Since I'm not a hardware expert I added linux-kernel to Cc, and
probably you should do the same (I added it to this one). But, until
you have any better advice I think you should do some long and heavy
testing of your PCs especially for overheating or memory problems.
We can start to analyze other bugs after we are sure the hardware is
OK.

BTW, probably your attachements are too big for the lists and the
message could be dropped. It would be better to add some link to a
server or use bugzilla for this.

Thanks,
Jarek P.
 
> 
> Attached all info that i was can get from PC. Maybe problem that we use
> Core Duo Quard processors? It's 64bit, but kernel and software compile
> as 32. On 2 x "OLD HT(2 core) Xeon 32 bit" PC all work great...
> 
> Simple step to reproduce
> Add iptables and tc rules.... give above 500 mbs total traffic (we have
> above 300/200 mbs in/out) from any (many?) ip what preset in TC rules
> and run any CPU like process (like compiling)...
> 
> Thanks for answers!
> 
> Denys Fedoryshchenko:
> Hello!
> i try run nmi_watchdog...
> i hope its helps, but this PC have hardware watchdog (bios have params
> for it), but kernel not have module for it - /S3210SH/ (ICH9-R chipset).
> I think simple not add ID to driver. I try write to author of it -
> wim@iguana.be.
> Please ask for me... this line:
> [    0.143332] APIC timer registered as dummy, due to nmi_watchdog=1!
> its normal start of nmi_watchdog? or i need use nmi_watchdog=2?
> 
> Thanks for answers!
> 
> > Denys Fedoryshchenko wrote, On 09/20/2008 08:11 PM:
> > ...
> >
> >   
> >> P.S. For netdev, i have one more friend - who is complaining that shapers is 
> >> crashing on Intel machines (who uses TSC, he have two different "Core" based 
> >> servers, and both is crashing). With HPET i dont have any problem on high 
> >> performance shapers (except, that it is CPU expensive). It happens on latest 
> >> 2.6.26.5 too. Machine getting hard lockup, and nothing than hardware watchdog 
> >> able to recover it. They dont have experience to get actual reason of this 
> >> issue and they dont know english well to report this issue.
> >>     
> >
> > Is your friend sure it's because of shapers? If he/she can patch
> > there is no need to know English well to report here:
> >
> > Subject: 2.6.26.5 tc not OK
> >
> > Config:
> > 	.config
> >
> > tc script:
> > 	script
> >
> > dmesg:
> > 	dmesg
> >
> > not OK when: script run/script not run
> >
> > patch #1 not OK
> > patch #2 not OK
> > ...
> > patch #2001 OK!
> >
> > Jarek P.
> >
> >   
> 








