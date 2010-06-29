From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: RE: [REGRESSION] e1000e stopped working
Date: Tue, 29 Jun 2010 13:32:09 +0300
Message-ID: <1277807529.19417.2.camel@localhost.localdomain>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
	 <1277660831.3321.3.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	 <1277745247.12841.1.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55938 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328Ab0F2KcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 06:32:14 -0400
Received: by fxm14 with SMTP id 14so1233309fxm.19
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 03:32:12 -0700 (PDT)
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-28 at 18:09 -0700, Allan, Bruce W wrote:
> On Monday, June 28, 2010 10:14 AM, Maxim Levitsky wrote:
> > On Mon, 2010-06-28 at 10:04 -0700, Allan, Bruce W wrote:
> >> On Sunday, June 27, 2010 10:47 AM, Maxim Levitsky wrote:
> >>> On Sun, 2010-06-27 at 20:43 +0300, Maxim Levitsky wrote:
> >>>> On Sun, 2010-06-27 at 20:29 +0300, Maxim Levitsky wrote:
> >>>>> On Sun, 2010-06-27 at 20:27 +0300, Maxim Levitsky wrote:
> >>>>>> Just that,
> >>>>>> 
> >>>>>> It doesn't receive anything from my internet router during DHCP.
> >>>>>> 
> >>>>>> 
> >>>>>> 00:19.0 Ethernet controller [0200]: Intel Corporation 82566DC
> >>>>>> 	Gigabit Network Connection [8086:104b] (rev 02) Subsystem: Intel
> >>>>>> 	Corporation Device [8086:0001] Control: I/O+ Mem+ BusMaster+
> >>>>>> 	SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >>>>>> 	DisINTx+ Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
> >>>>>> 	>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx- 	Latency: 0
> >>>>>> 	Interrupt: pin A routed to IRQ 47 Region 0: Memory at 50300000
> >>>>>> 	(32-bit, non-prefetchable) [size=128K] Region 1: Memory at
> >>>>>> 	50324000 (32-bit, non-prefetchable) [size=4K] Region 2: I/O
> >>>>>> 		ports at 30e0 [size=32] Capabilities: [c8] Power Management
> >>>>>> 		version 2 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> >>>>>> 	PME(D0+,D1-,D2-,D3hot+,D3cold+) Status: D0 PME-Enable- DSel=0
> >>>>>> 		DScale=1 PME- Capabilities: [d0] Message Signalled Interrupts:
> >>>>>> 	Mask- 64bit+ Queue=0/0 Enable+ Address: 00000000fee0100c  Data:
> >>>>>> 	41c9 Kernel driver in use: e1000e Kernel modules: e1000e
> >>>>>> 
> >>>>>> I use vanilla tree, commit
> >>>>>> bf2937695fe2330bfd8933a2310e7bdd2581dc2e 
> >>>>>> 
> >>>>>> 
> >>>>>> Best regards,
> >>>>>> 	Maxim Levitsky
> >>>>>> 
> >>>>> 
> >>>>> It appears to work now after reboot.
> >>>>> Will keep a look for this.
> >>>>> 
> >>>>> Disregard for now.
> >>>> 
> >>>> 
> >>>> Just s2ram cycle, problem is back.
> >>>> Did full reboot (power off then on), same thing card doesn't
> >>>> work... 
> >>>> 
> >>> 
> >>> Yep, s2ram sometimes 'fixes', sometimes breaks the card.
> >>> Something got broken in device initialization path.
> >>> 
> >>> Best regards,
> >>>  	Maxim Levitsky
> >> 
> >> What distro are you using?  If RedHat, since you are using DHCP will
> >> you please try putting a "LINKDELAY=10" in the
> >> /etc/sysconfig/network-scripts/ifcfg-ethX config file.  
> >> 
> > I use ubuntu 9.10
> > 
> >> Is there anything in the system log that might help narrow down the
> >> issue? 
> > 
> > Nothing, really nothing.
> > It seems to detect link, dhcp client sends requests, but doesn't
> > recieve a thing (even tried promisc mode - doesn't help)
> > 
> > 
> > 
> > Best regards,
> > 	Maxim Levitsky
> 
> Since you say this is a regression, when did this last work for you without this problem, i.e. which distro, which kernel?

I always compile kernel, and last kernel I compiled here was vanilla
2.6.33-rc4.
It works just fine.

I mostly use my laptop, and therefore didn't update kernel on my desktop
for long time.

If I find some free time I try to bisect the problem.



Best regards,
	Maxim Levitsky

