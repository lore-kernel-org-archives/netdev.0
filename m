From: "Jaswinder Singh" <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: BUG - ath9k keep on disconnecting in 2.6.28-rc8
Date: Sun, 14 Dec 2008 13:24:47 +0530
Message-ID: <3f9a31f40812132354k6f9e7b80o30d3236687dffba0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org, jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello all,

I am facing problem with 2.6.28-rc8, ath9k keep on disconnecting.

dmesg :
ath9k: 0.1
ath9k 0000:08:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
ath9k 0000:08:00.0: setting latency timer to 64
phy0: Selected rate control algorithm 'ath9k_rate_control'
Registered led device: ath9k-phy0:radio
Registered led device: ath9k-phy0:assoc
Registered led device: ath9k-phy0:tx
Registered led device: ath9k-phy0:rx
phy0: Atheros 9280: mem=0xffffc20006200000, irq=17

/sbin/lspci -vv :
08:00.0 Network controller: Atheros Communications Inc. Device 002a (rev 01)
	Subsystem: Hewlett-Packard Company Device 1381
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 128 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at d1100000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [60] Express (v1) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM unknown, Latency L0
<512ns, L1 <64us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [90] MSI-X: Enable- Mask- TabSize=1
		Vector table: BAR=0 offset=00000000
		PBA: BAR=0 offset=00000000
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq+ ACSVoil-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSVoil-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSVoil-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
	Kernel driver in use: ath9k
	Kernel modules: ath9k

Here are kernel messages telling disconnecting info :
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authentication with AP 00:11:95:9e:df:f6 timed out
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authentication with AP 00:11:95:9e:df:f6 timed out
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
ForceXPAon: 0
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authenticate with AP 00:11:95:9e:df:f6
wlan0: authentication with AP 00:11:95:9e:df:f6 timed out
wlan0: direct probe to AP 00:11:95:9e:df:f6 try 1
ForceXPAon: 0

If you need more information please let me know.

Thank you,

Jaswinder Singh.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
