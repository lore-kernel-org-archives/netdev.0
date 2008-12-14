From: "Jaswinder Singh" <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: BUG - ath9k keep on disconnecting in 2.6.28-rc8-tip
Date: Sun, 14 Dec 2008 13:44:15 +0530
Message-ID: <3f9a31f40812140014p7df48c4csc820ce1f0a4e65ee@mail.gmail.com>
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

I also tested with 2.6.28-rc8-tip also have ath9k disconnecting problem.

This seems to be more useful to debug the problem :

dmesg :
[    7.823228] ath9k: 0.1
[    7.823289] vendor=1022 device=9605
[    7.823289] ath9k 0000:08:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    7.823289] ath9k 0000:08:00.0: setting latency timer to 64
..
[    8.272013] phy0: Selected rate control algorithm 'ath9k_rate_control'
[    8.273900] Registered led device: ath9k-phy0:radio
[    8.273940] Registered led device: ath9k-phy0:assoc
[    8.273974] Registered led device: ath9k-phy0:tx
[    8.274012] Registered led device: ath9k-phy0:rx
..
[  230.478536] ForceXPAon: 0
[  230.549160] ForceXPAon: 0
[  230.620332] ForceXPAon: 0
[  230.626153] wlan0: authenticate with AP 00:11:95:9e:df:f6
[  230.627662] wlan0: authenticated
[  230.627686] wlan0: associate with AP 00:11:95:9e:df:f6
[  230.649736] wlan0: RX AssocResp from 00:11:95:9e:df:f6 (capab=0x471
status=0 aid=1)
[  230.649757] wlan0: associated
[  230.660043] ForceXPAon: 0
[  230.684015] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  240.875098] wlan0: no IPv6 routers present
..
[  515.696289] ForceXPAon: 0
[  515.767289] ForceXPAon: 0
[  515.838264] ForceXPAon: 0
[  515.909289] ForceXPAon: 0
[  515.980224] ForceXPAon: 0
[  516.051155] ForceXPAon: 0
[  516.123144] ForceXPAon: 0
[  516.194270] ForceXPAon: 0
[  516.265157] ForceXPAon: 0
[  516.337423] ForceXPAon: 0
[  614.483083] wlan0: No ProbeResp from current AP 00:11:95:9e:df:f6 -
assume out of range
[  614.624223] ForceXPAon: 0
[  614.888494] ForceXPAon: 0
[  615.087193] ForceXPAon: 0
[  615.357035] ForceXPAon: 0
[  615.428348] ForceXPAon: 0
..
[  616.138293] ForceXPAon: 0
[  616.209130] ForceXPAon: 0
[  616.280380] ForceXPAon: 0
[  616.284050] wlan0: authenticate with AP 00:11:95:9e:df:f6
[  616.285429] wlan0: authenticated
[  616.285453] wlan0: associate with AP 00:11:95:9e:df:f6
[  616.302631] wlan0: RX ReassocResp from 00:11:95:9e:df:f6
(capab=0x471 status=0 aid=1)
[  616.302652] wlan0: associated
[  616.313046] ForceXPAon: 0
[  633.435220] ForceXPAon: 0
..
[  995.686461] ForceXPAon: 0
[ 1009.687679] wlan0: No ProbeResp from current AP 00:11:95:9e:df:f6 -
assume out of range
[ 1009.830299] ForceXPAon: 0
[ 1010.093330] ForceXPAon: 0
[ 1010.292264] ForceXPAon: 0
..
[ 1011.341277] ForceXPAon: 0
[ 1011.412116] ForceXPAon: 0
[ 1011.483325] ForceXPAon: 0
[ 1011.489343] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1011.490862] wlan0: authenticated
[ 1011.490886] wlan0: associate with AP 00:11:95:9e:df:f6
[ 1011.504588] wlan0: RX ReassocResp from 00:11:95:9e:df:f6
(capab=0x471 status=0 aid=1)
[ 1011.504609] wlan0: associated
[ 1011.515043] ForceXPAon: 0
..
[ 1174.552258] ForceXPAon: 0
[ 1174.623299] ForceXPAon: 0
[ 1174.694583] ForceXPAon: 0
[ 1174.698288] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1174.699682] wlan0: authenticated
[ 1174.699688] wlan0: associate with AP 00:11:95:9e:df:f6
[ 1174.715849] wlan0: RX ReassocResp from 00:11:95:9e:df:f6
(capab=0x471 status=0 aid=1)
[ 1174.715854] wlan0: associated
[ 1174.726289] ForceXPAon: 0
[ 1188.726172] wlan0: No ProbeResp from current AP 00:11:95:9e:df:f6 -
assume out of range
[ 1188.867281] ForceXPAon: 0
[ 1189.128292] ForceXPAon: 0
[ 1189.326291] ForceXPAon: 0
[ 1189.589292] ForceXPAon: 0
[ 1189.661285] ForceXPAon: 0
[ 1189.732414] ForceXPAon: 0
[ 1189.803263] ForceXPAon: 0
[ 1189.874291] ForceXPAon: 0
[ 1189.945258] ForceXPAon: 0
[ 1190.016292] ForceXPAon: 0
[ 1190.087258] ForceXPAon: 0
[ 1190.158292] ForceXPAon: 0
[ 1190.229292] ForceXPAon: 0
[ 1190.300292] ForceXPAon: 0
[ 1190.371293] ForceXPAon: 0
[ 1190.442292] ForceXPAon: 0
[ 1190.513753] ForceXPAon: 0
[ 1190.518198] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1190.525032] ForceXPAon: 0
[ 1190.529337] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1190.729110] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1190.929264] wlan0: authenticate with AP 00:11:95:9e:df:f6
[ 1191.129109] wlan0: authentication with AP 00:11:95:9e:df:f6 timed out
[ 1204.184769] ForceXPAon: 0
[ 1204.196292] ForceXPAon: 0
[ 1204.459395] ForceXPAon: 0



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

If you need more information, Please let me know.

Thank you,

Jaswinder Singh.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
