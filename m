From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Wed, 11 Jul 2012 15:17:42 +0800
Message-ID: <4FFD2896.3090209@oracle.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891274EEF38@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 07/11/12 15:11, Dave, Tushar N wrote:
>> -----Original Message-----
>> From: Joe Jin [mailto:joe.jin@oracle.com]
>> Sent: Tuesday, July 10, 2012 10:03 PM
>> To: Dave, Tushar N
>> Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: 82571EB: Detected Hardware Unit Hang
>>
>> On 07/11/12 12:05, Dave, Tushar N wrote:
>>> When you said you had this issue with RHEL5 and RHEL6 drivers, have you
>> install RHEl5/6 kernel and reproduced it? If so I think I should install
>> RHEL6 and try reproduce it locally!
>>>
>> Yes I reproduced this on both RHEL5 and RHEL6.
>>
>> So far I tried to scp big file (~1GB) will hit it at once.
>>
>> Thanks,
>> Joe
> 
> Joe,
> Can you please send lspci -vvv output for failing port before issue occurs.
> Thanks.
> 
# lspci -s 05:00.0 -vvv
05:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (Copper) (rev 06)
	Subsystem: Oracle Corporation x4 PCI-Express Quad Gigabit Ethernet UTP Low Profile Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 256 bytes
	Interrupt: pin B routed to IRQ 80
	Region 0: Memory at fbde0000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at fbdc0000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at dc00 [size=32]
	Expansion ROM at fbda0000 [disabled] [size=128K]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee21000  Data: 40cb
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 <4us, L1 <64us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt- UnxCmplt- RxOF- MalfTLP+ ECRC- UnsupReq+ ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 12, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140 v1] Device Serial Number 00-15-17-ff-ff-b9-77-9c
	Kernel driver in use: e1000e
	Kernel modules: e1000e


Thanks,
Joe

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
