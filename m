From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [REGRESSION] e1000e stopped working
Date: Mon, 28 Jun 2010 10:04:59 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
 <1277660831.3321.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Maxim Levitsky <maximlevitsky@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3460 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671Ab0F1RFB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 13:05:01 -0400
In-Reply-To: <1277660831.3321.3.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, June 27, 2010 10:47 AM, Maxim Levitsky wrote:
> On Sun, 2010-06-27 at 20:43 +0300, Maxim Levitsky wrote:
>> On Sun, 2010-06-27 at 20:29 +0300, Maxim Levitsky wrote:
>>> On Sun, 2010-06-27 at 20:27 +0300, Maxim Levitsky wrote:
>>>> Just that,
>>>> 
>>>> It doesn't receive anything from my internet router during DHCP.
>>>> 
>>>> 
>>>> 00:19.0 Ethernet controller [0200]: Intel Corporation 82566DC
>>>> 	Gigabit Network Connection [8086:104b] (rev 02) Subsystem: Intel
>>>> 	Corporation Device [8086:0001] Control: I/O+ Mem+ BusMaster+
>>>> 	SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>>>> 	DisINTx+ Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
>>>> 	>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx- 	Latency: 0
>>>> 	Interrupt: pin A routed to IRQ 47 Region 0: Memory at 50300000
>>>> 	(32-bit, non-prefetchable) [size=128K] Region 1: Memory at
>>>> 	50324000 (32-bit, non-prefetchable) [size=4K] Region 2: I/O ports
>>>> 		at 30e0 [size=32] Capabilities: [c8] Power Management version 2
>>>> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
>>>> 	PME(D0+,D1-,D2-,D3hot+,D3cold+) Status: D0 PME-Enable- DSel=0
>>>> 		DScale=1 PME- Capabilities: [d0] Message Signalled Interrupts:
>>>> 	Mask- 64bit+ Queue=0/0 Enable+ Address: 00000000fee0100c  Data:
>>>> 	41c9 Kernel driver in use: e1000e Kernel modules: e1000e
>>>> 
>>>> I use vanilla tree, commit bf2937695fe2330bfd8933a2310e7bdd2581dc2e
>>>> 
>>>> 
>>>> Best regards,
>>>> 	Maxim Levitsky
>>>> 
>>> 
>>> It appears to work now after reboot.
>>> Will keep a look for this.
>>> 
>>> Disregard for now.
>> 
>> 
>> Just s2ram cycle, problem is back.
>> Did full reboot (power off then on), same thing card doesn't work...
>> 
> 
> Yep, s2ram sometimes 'fixes', sometimes breaks the card.
> Something got broken in device initialization path.
> 
> Best regards,
>  	Maxim Levitsky

What distro are you using?  If RedHat, since you are using DHCP will you please try putting a "LINKDELAY=10" in the /etc/sysconfig/network-scripts/ifcfg-ethX config file.

Is there anything in the system log that might help narrow down the issue?

Thanks,
Bruce.
