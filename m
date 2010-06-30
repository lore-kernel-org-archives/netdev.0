From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: RE: [REGRESSION] e1000e stopped working
Date: Thu, 01 Jul 2010 01:59:17 +0300
Message-ID: <1277938757.4138.3.camel@localhost.localdomain>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
	 <1277660831.3321.3.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	 <1277745247.12841.1.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	 <1277807529.19417.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WU54L9awGei0t+wp+4IM"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50940 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab0F3W7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 18:59:24 -0400
Received: by fxm14 with SMTP id 14so827665fxm.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 15:59:22 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WU54L9awGei0t+wp+4IM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2010-06-29 at 12:37 -0600, Tantilov, Emil S wrote:
> Maxim Levitsky wrote:
> > On Mon, 2010-06-28 at 18:09 -0700, Allan, Bruce W wrote:
> >> On Monday, June 28, 2010 10:14 AM, Maxim Levitsky wrote:
> >>> On Mon, 2010-06-28 at 10:04 -0700, Allan, Bruce W wrote:
> >>>> On Sunday, June 27, 2010 10:47 AM, Maxim Levitsky wrote:
> >>>>> On Sun, 2010-06-27 at 20:43 +0300, Maxim Levitsky wrote:
> >>>>>> On Sun, 2010-06-27 at 20:29 +0300, Maxim Levitsky wrote:
> >>>>>>> On Sun, 2010-06-27 at 20:27 +0300, Maxim Levitsky wrote:
> >>>>>>>> Just that,
> >>>>>>>> 
> >>>>>>>> It doesn't receive anything from my internet router during
> >>>>>>>> DHCP. 
> >>>>>>>> 
> >>>>>>>> 
> >>>>>>>> 00:19.0 Ethernet controller [0200]: Intel Corporation 82566DC
> >>>>>>>> 	Gigabit Network Connection [8086:104b] (rev 02) Subsystem:
> >>>>>>>> 	Intel Corporation Device [8086:0001] Control: I/O+ Mem+
> >>>>>>>> 	BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping-
> >>>>>>>> 	SERR- FastB2B- DisINTx+ Status: Cap+ 66MHz- UDF- FastB2B-
> >>>>>>>> 	ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >>>>>>>> 	INTx- 	Latency: 0 Interrupt: pin A routed to IRQ 47 Region 0:
> >>>>>>>> 	Memory at 50300000 (32-bit, non-prefetchable) [size=128K]
> >>>>>>>> 	Region 1: Memory at 50324000 (32-bit, non-prefetchable)
> >>>>>>>> 		[size=4K] Region 2: I/O ports at 30e0 [size=32]
> >>>>>>>> 		Capabilities: [c8] Power Management version 2 Flags: PMEClk-
> >>>>>>>> 	DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> >>>>>>>> 		Status: D0 PME-Enable- DSel=0 DScale=1 PME- Capabilities:
> >>>>>>>> 	[d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0
> >>>>>>>> 	Enable+ Address: 00000000fee0100c  Data: 41c9 Kernel driver
> >>>>>>>> in use: e1000e Kernel modules: e1000e 
> >>>>>>>> 
> >>>>>>>> I use vanilla tree, commit
> >>>>>>>> bf2937695fe2330bfd8933a2310e7bdd2581dc2e
> >>>>>>>> 
> >>>>>>>> 
> >>>>>>>> Best regards,
> >>>>>>>> 	Maxim Levitsky
> >>>>>>>> 
> >>>>>>> 
> >>>>>>> It appears to work now after reboot.
> >>>>>>> Will keep a look for this.
> >>>>>>> 
> >>>>>>> Disregard for now.
> >>>>>> 
> >>>>>> 
> >>>>>> Just s2ram cycle, problem is back.
> >>>>>> Did full reboot (power off then on), same thing card doesn't
> >>>>>> work... 
> >>>>>> 
> >>>>> 
> >>>>> Yep, s2ram sometimes 'fixes', sometimes breaks the card.
> >>>>> Something got broken in device initialization path.
> >>>>> 
> >>>>> Best regards,
> >>>>>  	Maxim Levitsky
> >>>> 
> >>>> What distro are you using?  If RedHat, since you are using DHCP
> >>>> will you please try putting a "LINKDELAY=10" in the
> >>>> /etc/sysconfig/network-scripts/ifcfg-ethX config file.
> >>>> 
> >>> I use ubuntu 9.10
> >>> 
> >>>> Is there anything in the system log that might help narrow down the
> >>>> issue?
> >>> 
> >>> Nothing, really nothing.
> >>> It seems to detect link, dhcp client sends requests, but doesn't
> >>> recieve a thing (even tried promisc mode - doesn't help)
> >>> 
> >>> 
> >>> 
> >>> Best regards,
> >>> 	Maxim Levitsky
> >> 
> >> Since you say this is a regression, when did this last work for you
> >> without this problem, i.e. which distro, which kernel? 
> > 
> > I always compile kernel, and last kernel I compiled here was vanilla
> > 2.6.33-rc4.
> > It works just fine.
> > 
> > I mostly use my laptop, and therefore didn't update kernel on my
> > desktop for long time.
> > 
> > If I find some free time I try to bisect the problem.
> 
> Could you provide some additional info about your setup:
> ethtool -e eth0
> ethtool -d eth0
> kernel config (if possible)
> 
> What is the model of your system/MB?


Sure,


My motherboard on this system is Intel DG965RY

The bug in about 90% reproducible.
Doing several s2ram cycles, its possible to catch a moment when the
device starts working.


Best regards,
	Maxim Levitsky



--=-WU54L9awGei0t+wp+4IM
Content-Disposition: attachment; filename="eeprom"
Content-Type: text/plain; name="eeprom"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Offset		Values
------		------
0x0000		00 19 d1 ed 88 2a 00 08 ff ff 10 10 ff ff ff ff 
0x0010		ff ff ff ff c7 10 01 00 86 80 4b 10 86 80 00 00 
0x0020		01 0d 00 00 00 00 05 96 20 50 00 33 00 00 07 8d 
0x0030		84 06 41 03 00 00 00 00 00 00 00 00 00 00 00 00 
0x0040		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060		00 01 00 40 2a 12 07 40 ff ff ff ff ff ff ff ff 
0x0070		ff ff ff ff ff ff ff ff ff ff ff ff ff ff 1f ff 
0x0080		20 61 1f 00 02 0e 12 00 40 2f 1f 00 18 90 1b 00 
0x0090		00 00 12 00 a0 2f 1f 00 24 8b 11 00 f0 f8 12 00 
0x00a0		00 20 1f 00 b0 10 10 00 00 00 11 00 c0 20 1f 00 
0x00b0		9a 24 1d 00 d3 00 1e 00 a0 28 1f 00 ce 04 14 00 
0x00c0		60 2f 1f 00 e4 29 10 00 00 00 1f 00 40 01 00 00 
0x00d0		20 1f 1f 00 06 16 10 00 14 b8 11 00 2a 01 15 00 
0x00e0		67 00 1e 00 40 1f 1f 00 65 00 14 00 2a 00 15 00 
0x00f0		2a 00 16 00 60 1f 1f 00 b0 3f 12 00 ff c0 16 00 
0x0100		ec 1d 17 00 ef f9 18 00 10 02 19 00 80 18 1f 00 
0x0110		03 00 15 00 80 17 1f 00 08 00 16 00 80 17 1f 00 
0x0120		08 d0 18 00 80 18 1f 00 18 d9 18 00 60 18 1f 00 
0x0130		00 08 1a 00 00 00 1f 00 01 00 19 00 40 13 00 00 
0x0140		51 60 1f 00 01 00 11 00 00 00 1f 00 ff ff ff ff 
0x0150		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0160		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0170		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0180		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0190		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0200		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0210		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0220		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0230		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0240		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0250		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0260		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0270		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0280		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0290		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0300		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0310		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0320		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0330		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0340		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0350		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0360		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0370		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0380		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0390		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0400		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0410		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0420		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0430		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0440		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0450		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0460		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0470		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0480		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0490		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0500		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0510		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0520		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0530		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0540		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0550		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0560		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0570		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0580		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0590		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0600		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0610		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0620		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0630		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0640		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0650		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0660		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0670		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0680		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0690		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0700		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0710		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0720		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0730		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0740		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0750		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0760		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0770		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0780		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0790		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0800		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0810		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0820		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0830		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0840		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0850		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0860		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0870		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0880		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0890		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0900		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0910		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0920		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0930		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0940		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0950		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0960		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0970		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0980		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0990		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0aa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ab0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ac0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ad0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ae0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0af0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ba0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0be0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ca0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ce0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0da0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0db0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0de0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0df0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ea0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0eb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ec0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ed0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ee0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ef0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fe0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ff0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

--=-WU54L9awGei0t+wp+4IM
Content-Disposition: attachment; filename="misc"
Content-Type: text/plain; name="misc"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

maxim@MAIN:~$ sudo ethtool -i eth1
driver: e1000e
version: 1.0.2-k4
firmware-version: 1.1-0
bus-info: 0000:00:19.0

maxim@MAIN:~$ sudo ethtool -g eth1 
Ring parameters for eth1:
Pre-set maximums:
RX:		4096
RX Mini:	0
RX Jumbo:	0
TX:		4096
Current hardware settings:
RX:		256
RX Mini:	0
RX Jumbo:	0
TX:		256


maxim@MAIN:~$ ifconfig 
eth1      Link encap:Ethernet  HWaddr 00:19:d1:ed:88:2a  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:18 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3411 (3.4 KB)  TX bytes:2736 (2.7 KB)
          Interrupt:20 Memory:50300000-50320000 


Number of RX packets seems to increase
Wireshark doesn't see them


Example:

maxim@MAIN:~$ sudo dhclient eth1
Internet Systems Consortium DHCP Client V3.1.2
Copyright 2004-2008 Internet Systems Consortium.
All rights reserved.
For info, please visit http://www.isc.org/sw/dhcp/

Listening on LPF/eth1/00:19:d1:ed:88:2a
Sending on   LPF/eth1/00:19:d1:ed:88:2a
Sending on   Socket/fallback
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 6
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 11
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 18





--=-WU54L9awGei0t+wp+4IM
Content-Type: audio/x-ape; name="reg_dump"
Content-Disposition: attachment; filename="reg_dump"
Content-Transfer-Encoding: 7bit

MAC Registers
-------------
0x00000: CTRL (Device control register)  0x18100240
      Endian mode (buffers):             little
      Link reset:                        normal
      Set link up:                       1
      Invert Loss-Of-Signal:             no
      Receive flow control:              enabled
      Transmit flow control:             enabled
      VLAN mode:                         disabled
      Auto speed detect:                 disabled
      Speed select:                      1000Mb/s
      Force speed:                       no
      Force duplex:                      no
0x00008: STATUS (Device status register) 0x00080263
      Duplex:                            full
      Link up:                           link config
      TBI mode:                          enabled
      Link speed:                        100Mb/s
      Bus type:                          PCI Express
      Port number:                       0
0x00100: RCTL (Receive control register) 0x04008002
      Receiver:                          enabled
      Store bad packets:                 disabled
      Unicast promiscuous:               disabled
      Multicast promiscuous:             disabled
      Long packet:                       disabled
      Descriptor minimum threshold size: 1/2
      Broadcast accept mode:             accept
      VLAN filter:                       disabled
      Canonical form indicator:          disabled
      Discard pause frames:              filtered
      Pass MAC control frames:           don't pass
      Receive buffer size:               2048
0x02808: RDLEN (Receive desc length)     0x00001000
0x02810: RDH   (Receive desc head)       0x0000000B
0x02818: RDT   (Receive desc tail)       0x00000000
0x02820: RDTR  (Receive delay timer)     0x00000000
0x00400: TCTL (Transmit ctrl register)   0x3103F0FA
      Transmitter:                       enabled
      Pad short packets:                 enabled
      Software XOFF Transmission:        disabled
      Re-transmit on late collision:     enabled
0x03808: TDLEN (Transmit desc length)    0x00001000
0x03810: TDH   (Transmit desc head)      0x00000006
0x03818: TDT   (Transmit desc tail)      0x00000006
0x03820: TIDV  (Transmit delay timer)    0x00000008
PHY type:                                unknown

--=-WU54L9awGei0t+wp+4IM
Content-Type: application/x-gzip; name=".config.gz"
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
wba6miWun1FS1q1foar6/wGJBE7RyggBAJ==


--=-WU54L9awGei0t+wp+4IM--

