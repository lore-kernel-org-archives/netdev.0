From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Wed, 11 Jul 2012 07:50:16 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274EF055@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com>
 <4FFCCA22.8060006@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
 <4FFCDA6C.8020708@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
 <4FFCF314.6020400@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
 <4FFD0908.6080506@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEF38@ORSMSX102.amr.corp.intel.com>
 <4FFD2896.3090209@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEFD7@ORSMSX102.amr.corp.intel.com>
 <4FFD2D7E.60801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFD2D7E.60801@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Wednesday, July 11, 2012 12:39 AM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/11/12 15:37, Dave, Tushar N wrote:
>>> -----Original Message-----
>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>> Sent: Wednesday, July 11, 2012 12:18 AM
>>> To: Dave, Tushar N
>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>> kernel@vger.kernel.org
>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>
>>> On 07/11/12 15:11, Dave, Tushar N wrote:
>>>>> -----Original Message-----
>>>>> From: Joe Jin [mailto:joe.jin@oracle.com]
>>>>> Sent: Tuesday, July 10, 2012 10:03 PM
>>>>> To: Dave, Tushar N
>>>>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>>>>> kernel@vger.kernel.org
>>>>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>>>>
>>>>> On 07/11/12 12:05, Dave, Tushar N wrote:
>>>>>> When you said you had this issue with RHEL5 and RHEL6 drivers,
>>>>>> have you
>>>>> install RHEl5/6 kernel and reproduced it? If so I think I should
>>>>> install
>>>>> RHEL6 and try reproduce it locally!
>>>>>>
>>>>> Yes I reproduced this on both RHEL5 and RHEL6.
>>>>>
>>>>> So far I tried to scp big file (~1GB) will hit it at once.
>>>>>
>>>>> Thanks,
>>>>> Joe
>>>>
>>>> Joe,
>>>> Can you please send lspci -vvv output for failing port before issue
>>> occurs.
>>>> Thanks.
>>>>
>>> # lspci -s 05:00.0 -vvv
>>> 05:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit
>>> Ethernet Controller (Copper) (rev 06)
>>> 	Subsystem: Oracle Corporation x4 PCI-Express Quad Gigabit Ethernet
>>> UTP Low Profile Adapter
>>> 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
>>> Stepping- SERR- FastB2B- DisINTx+
>>> 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>>> <TAbort- <MAbort- >SERR- <PERR- INTx-
>>> 	Latency: 0, Cache Line Size: 256 bytes
>>> 	Interrupt: pin B routed to IRQ 80
>>> 	Region 0: Memory at fbde0000 (32-bit, non-prefetchable) [size=128K]
>>> 	Region 1: Memory at fbdc0000 (32-bit, non-prefetchable) [size=128K]
>>> 	Region 2: I/O ports at dc00 [size=32]
>>> 	Expansion ROM at fbda0000 [disabled] [size=128K]
>>> 	Capabilities: [c8] Power Management version 2
>>> 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-
>>> ,D3hot+,D3cold+)
>>> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>>> 	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>>> 		Address: 00000000fee21000  Data: 40cb
>>> 	Capabilities: [e0] Express (v1) Endpoint, MSI 00
>>> 		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s
>>> <512ns, L1 <64us
>>> 			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
>>> 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal-
>>> Unsupported-
>>> 			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>> 			MaxPayload 128 bytes, MaxReadReq 512 bytes
>>> 		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+
>>> TransPend-
>>> 		LnkCap:	Port #2, Speed 2.5GT/s, Width x4, ASPM L0s,
>>> Latency L0 <4us, L1 <64us
>>> 			ClockPM- Surprise- LLActRep- BwNot-
>>> 		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain-
>>> CommClk-
>>> 			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>> 		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+
>>> DLActive- BWMgmt- ABWMgmt-
>>> 	Capabilities: [100 v1] Advanced Error Reporting
>>> 		UESta:	DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt- UnxCmplt-
>>> RxOF- MalfTLP+ ECRC- UnsupReq+ ACSViol-
>>> 		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
>>> RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>>> 		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
>>> UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>>> 		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>>> 		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>>> 		AERCap:	First Error Pointer: 12, GenCap- CGenEn- ChkCap-
>>> ChkEn-
>>> 	Capabilities: [140 v1] Device Serial Number 00-15-17-ff-ff-b9-77-9c
>>> 	Kernel driver in use: e1000e
>>> 	Kernel modules: e1000e
>>>
>>>
>>> Thanks,
>>> Joe
>>
>> was this lspci output taken on freshly booted system?
>>
>
>Yes, any issue do you find?
>
>Thanks,
>Joe
>

Device status and AER sections show some errors that looks little suspicious to me but I'm not too sure. I will get back tomorrow.

-Tushar
