From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Mon, 01 Dec 2014 23:06:27 +0100
Message-ID: <2050946.b5N4SjBTNU@eisbaer>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <5471AC29.6040009@broadcom.com> <5475A2DC.80502@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1987831.oYbR9djWU6"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:60417 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932323AbaLAWGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 17:06:37 -0500
In-Reply-To: <5475A2DC.80502@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1987831.oYbR9djWU6
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi Arend,

sorry for my late reply, it took me a bit to get the modules compiled with 
your patches. Here is the information from my card. During this test I had 
very bad performance with my wifi connection with big latency and lots of 
packet loss.

[ 1642.407735] bcma: bus0: Found chip with id 0x4313, rev 0x01 and package 0x08
[ 1642.407766] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x24, class 0x0)
[ 1642.407794] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x18, class 0x0)
[ 1642.407829] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x11, class 0x0)
[ 1642.407913] bcma: bus0: Found rev 8 PMU (capabilities 0x084C3008)
[ 1642.407978] bcma: bus0: SPROM offset 0x830
[ 1642.410625] bcma: bcmasprom:
[ 1642.410630] bcma: 
        
[ 1642.410635] bcma: 2801 
[ 1642.410637] bcma: 0000 
[ 1642.410640] bcma: 0608 
[ 1642.410642] bcma: 14E4 
[ 1642.410645] bcma: 0070 
[ 1642.410647] bcma: EDBE 
[ 1642.410649] bcma: 0000 
[ 1642.410651] bcma: 2BC4 
[ 1642.410654] bcma: 2A64 
[ 1642.410655] bcma: 2964 
[ 1642.410658] bcma: 
        
[ 1642.410659] bcma: 2C64 
[ 1642.410662] bcma: 3CE7 
[ 1642.410663] bcma: 46FF 
[ 1642.410666] bcma: 47FF 
[ 1642.410667] bcma: 0C00 
[ 1642.410670] bcma: 0820 
[ 1642.410671] bcma: 0030 
[ 1642.410674] bcma: 1002 
[ 1642.410676] bcma: 9F28 
[ 1642.410678] bcma: 5D44 
[ 1642.410679] bcma: 
        
[ 1642.410683] bcma: 8080 
[ 1642.410684] bcma: 1D8F 
[ 1642.410687] bcma: 0032 
[ 1642.410689] bcma: 0100 
[ 1642.410691] bcma: DF00 
[ 1642.410693] bcma: 71F5 
[ 1642.410695] bcma: 8400 
[ 1642.410697] bcma: 0083 
[ 1642.410699] bcma: 8500 
[ 1642.410701] bcma: 2010 
[ 1642.410703] bcma: 
        
[ 1642.410705] bcma: 0001 
[ 1642.410707] bcma: 0000 
[ 1642.410709] bcma: 0000 
[ 1642.410711] bcma: 0000 
[ 1642.410713] bcma: 0000 
[ 1642.410715] bcma: 0000 
[ 1642.410717] bcma: 0000 
[ 1642.410719] bcma: 0000 
[ 1642.410721] bcma: 0000 
[ 1642.410723] bcma: 0000 
[ 1642.410724] bcma: 
        
[ 1642.410728] bcma: 0000 
[ 1642.410730] bcma: 0000 
[ 1642.410732] bcma: 1008 
[ 1642.410734] bcma: 0305 
[ 1642.410736] bcma: 0000 
[ 1642.410738] bcma: 0000 
[ 1642.410740] bcma: 0000 
[ 1642.410742] bcma: 0000 
[ 1642.410744] bcma: 4727 
[ 1642.410746] bcma: 8000 
[ 1642.410748] bcma: 
        
[ 1642.410749] bcma: 0002 
[ 1642.410752] bcma: 0000 
[ 1642.410753] bcma: 1F30 
[ 1642.410756] bcma: 1800 
[ 1642.410757] bcma: 0000 
[ 1642.410760] bcma: 0000 
[ 1642.410761] bcma: 0000 
[ 1642.410764] bcma: 0000 
[ 1642.410765] bcma: 0000 
[ 1642.410768] bcma: 0000 
[ 1642.410769] bcma: 
        
[ 1642.410773] bcma: 0000 
[ 1642.410774] bcma: 0000 
[ 1642.410777] bcma: 0000 
[ 1642.410778] bcma: 0000 
[ 1642.410781] bcma: 5372 
[ 1642.410782] bcma: 1109 
[ 1642.410785] bcma: 2201 
[ 1642.410786] bcma: 0040 
[ 1642.410789] bcma: 0884 
[ 1642.410790] bcma: 0000 
[ 1642.410793] bcma: 
        
[ 1642.410794] bcma: C014 
[ 1642.410797] bcma: 3DC1 
[ 1642.410798] bcma: 809D 
[ 1642.410801] bcma: 5856 
[ 1642.410802] bcma: 0001 
[ 1642.410805] bcma: FFFF 
[ 1642.410807] bcma: 83FF 
[ 1642.410809] bcma: FFFF 
[ 1642.410811] bcma: 0003 
[ 1642.410813] bcma: 0202 
[ 1642.410814] bcma: 
        
[ 1642.410818] bcma: FFFF 
[ 1642.410819] bcma: 0011 
[ 1642.410822] bcma: 017A 
[ 1642.410824] bcma: 0000 
[ 1642.410826] bcma: 0000 
[ 1642.410828] bcma: 0000 
[ 1642.410830] bcma: 0000 
[ 1642.410832] bcma: 0201 
[ 1642.410834] bcma: 0000 
[ 1642.410836] bcma: 7800 
[ 1642.410838] bcma: 
        
[ 1642.410839] bcma: 01FF 
[ 1642.410842] bcma: E398 
[ 1642.410844] bcma: 0008 
[ 1642.410846] bcma: 0000 
[ 1642.410848] bcma: 0000 
[ 1642.410850] bcma: 0000 
[ 1642.410852] bcma: 0044 
[ 1642.410854] bcma: 2400 
[ 1642.410856] bcma: FCF7 
[ 1642.410858] bcma: 0089 
[ 1642.410860] bcma: 
        
[ 1642.410863] bcma: 0000 
[ 1642.410865] bcma: 0000 
[ 1642.410867] bcma: 0000 
[ 1642.410869] bcma: 0000 
[ 1642.410871] bcma: 0000 
[ 1642.410873] bcma: 0000 
[ 1642.410875] bcma: 0000 
[ 1642.410877] bcma: 0000 
[ 1642.410879] bcma: 0000 
[ 1642.410881] bcma: 0000 
[ 1642.410883] bcma: 
        
[ 1642.410884] bcma: 0000 
[ 1642.410887] bcma: 0000 
[ 1642.410888] bcma: 0048 
[ 1642.410891] bcma: FED2 
[ 1642.410892] bcma: 15D9 
[ 1642.410895] bcma: FAC6 
[ 1642.410897] bcma: 0000 
[ 1642.410899] bcma: 0000 
[ 1642.410901] bcma: 0000 
[ 1642.410903] bcma: 0000 
[ 1642.410904] bcma: 
        
[ 1642.410908] bcma: 0000 
[ 1642.410909] bcma: 0000 
[ 1642.410912] bcma: 0000 
[ 1642.410913] bcma: 0000 
[ 1642.410916] bcma: 0000 
[ 1642.410917] bcma: 0000 
[ 1642.410920] bcma: 0000 
[ 1642.410921] bcma: 0000 
[ 1642.410924] bcma: 0000 
[ 1642.410925] bcma: 0000 
[ 1642.410927] bcma: 
        
[ 1642.410929] bcma: 0000 
[ 1642.410931] bcma: 0000 
[ 1642.410933] bcma: 0000 
[ 1642.410935] bcma: 0000 
[ 1642.410937] bcma: 0000 
[ 1642.410939] bcma: 0000 
[ 1642.410941] bcma: 0000 
[ 1642.410943] bcma: 0000 
[ 1642.410945] bcma: 0000 
[ 1642.410947] bcma: 0000 
[ 1642.410949] bcma: 
        
[ 1642.410952] bcma: 0000 
[ 1642.410954] bcma: 0000 
[ 1642.410956] bcma: 0000 
[ 1642.410958] bcma: 0000 
[ 1642.410960] bcma: 0000 
[ 1642.410962] bcma: 0000 
[ 1642.410964] bcma: 0000 
[ 1642.410966] bcma: 0000 
[ 1642.410968] bcma: 0000 
[ 1642.410970] bcma: 0000 
[ 1642.410972] bcma: 
        
[ 1642.410974] bcma: 0000 
[ 1642.410976] bcma: 0000 
[ 1642.410978] bcma: 0000 
[ 1642.410980] bcma: 0000 
[ 1642.410982] bcma: 0000 
[ 1642.410984] bcma: 0000 
[ 1642.410986] bcma: 0000 
[ 1642.410988] bcma: 0000 
[ 1642.410990] bcma: 0000 
[ 1642.410992] bcma: 0000 
[ 1642.410994] bcma: 
        
[ 1642.410997] bcma: 0000 
[ 1642.410999] bcma: 1111 
[ 1642.411001] bcma: 1111 
[ 1642.411003] bcma: 0000 
[ 1642.411005] bcma: 0000 
[ 1642.411007] bcma: 0000 
[ 1642.411009] bcma: 0000 
[ 1642.411010] bcma: 0000 
[ 1642.411013] bcma: 0000 
[ 1642.411015] bcma: 2222 
[ 1642.411017] bcma: 
        
[ 1642.411018] bcma: 3222 
[ 1642.411021] bcma: 0000 
[ 1642.411022] bcma: 0000 
[ 1642.411025] bcma: 0000 
[ 1642.411026] bcma: 0000 
[ 1642.411029] bcma: 0000 
[ 1642.411030] bcma: 0000 
[ 1642.411033] bcma: 0000 
[ 1642.411034] bcma: 0000 
[ 1642.411037] bcma: 0000 
[ 1642.411038] bcma: 
        
[ 1642.411041] bcma: 0000 
[ 1642.411043] bcma: 0000 
[ 1642.411045] bcma: 0000 
[ 1642.411047] bcma: 0000 
[ 1642.411050] bcma: 0000 
[ 1642.411051] bcma: 0000 
[ 1642.411054] bcma: 0000 
[ 1642.411055] bcma: 0000 
[ 1642.411058] bcma: 0000 
[ 1642.411059] bcma: 0000 
[ 1642.411061] bcma: 
        
[ 1642.411063] bcma: 0000 
[ 1642.411065] bcma: 0000 
[ 1642.411067] bcma: 0000 
[ 1642.411069] bcma: 0000 
[ 1642.411071] bcma: 0000 
[ 1642.411073] bcma: 0000 
[ 1642.411075] bcma: 0000 
[ 1642.411077] bcma: 0000 
[ 1642.411079] bcma: 0000 
[ 1642.411081] bcma: 0000 
[ 1642.411083] bcma: 
        
[ 1642.411086] bcma: 0000 
[ 1642.411088] bcma: 0000 
[ 1642.411090] bcma: 0000 
[ 1642.411092] bcma: 0000 
[ 1642.411094] bcma: 0000 
[ 1642.411096] bcma: 0000 
[ 1642.411098] bcma: 0000 
[ 1642.411100] bcma: 0000 
[ 1642.411102] bcma: 0000 
[ 1642.411104] bcma: 0000 
[ 1642.411106] bcma: 
        
[ 1642.411107] bcma: 0000 
[ 1642.411110] bcma: 0000 
[ 1642.411111] bcma: 0000 
[ 1642.411114] bcma: 0000 
[ 1642.411115] bcma: 0000 
[ 1642.411118] bcma: 0000 
[ 1642.411119] bcma: 0000 
[ 1642.411122] bcma: 0000 
[ 1642.411123] bcma: 0000 
[ 1642.411127] bcma: bus0: Found SPROM revision 8
[ 1642.434510] bcma: bus0: GPIO driver not activated
[ 1642.434518] bcma: bus0: Bus registered
[ 1642.449971] brcmsmac bcma0:0: mfg 4bf core 812 rev 24 class 0 irq 17
[ 1642.450095] bcma: bus0: Switched to core: 0x812
[ 1642.451446] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'




[ 4112.897927] brcmsmac bcma0:0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[ 4112.898113] brcmsmac bcma0:0: brcms_ops_config: change power-save mode: false (implement)
[ 4112.899832] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[ 4113.830658] wlan0: authenticate with e8:de:27:44:3b:33
[ 4113.830764] wlan0: send auth to e8:de:27:44:3b:33 (try 1/3)
[ 4113.832620] wlan0: authenticated
[ 4113.833859] wlan0: associate with e8:de:27:44:3b:33 (try 1/3)
[ 4113.837231] wlan0: RX AssocResp from e8:de:27:44:3b:33 (capab=0x431 status=0 aid=1)
[ 4113.837591] brcmsmac bcma0:0: brcmsmac: brcms_ops_bss_info_changed: associated
[ 4113.837752] brcmsmac bcma0:0: brcms_ops_bss_info_changed: arp filtering: 1 addresses (implement)
[ 4113.837861] brcmsmac bcma0:0: brcms_ops_bss_info_changed: qos enabled: true (implement)
[ 4113.838209] wlan0: associated
[ 4113.838228] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[ 4113.838771] cfg80211: Calling CRDA for country: DE
[ 4113.847285] cfg80211: Regulatory domain changed to country: DE
[ 4113.847298] cfg80211:  DFS Master region: ETSI
[ 4113.847302] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[ 4113.847308] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[ 4113.847313] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[ 4113.847318] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz), (N/A, 2000 mBm), (0 s)
[ 4113.847322] cfg80211:   (5470000 KHz - 5725000 KHz @ 80000 KHz), (N/A, 2698 mBm), (0 s)
[ 4113.847327] cfg80211:   (57240000 KHz - 65880000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)



$ cat brcmsmac/bcma0\:0/hardware 
chipnum 0x4313
chiprev 0x1
chippackage 0x8
corerev 0x18
boardid 0x608
boardvendor 0x14e4
boardrev P109
boardflags 0x402201
boardflags2 0x884
ucoderev 0x262032c
radiorev 0x1
phytype 0x8
phyrev 0x1
anarev 0xa
nvramrev 8


$ cat brcmsmac/bcma0\:0/macstat 
txallfrm: 1622
txrtsfrm: 739
txctsfrm: 269
txackfrm: 128
txdnlfrm: 0
txbcnfrm: 0
txfunfl[8]: 0 0 0 0 0 0 0 0
txtplunfl: 0
txphyerr: 0
pktengrxducast: 0
pktengrxdmcast: 0
rxfrmtoolong: 927
rxfrmtooshrt: 158
rxinvmachdr: 3145
rxbadfcs: 7459
rxbadplcp: 28631
rxcrsglitch: 945
rxstrt: 17138
rxdfrmucastmbss: 112
rxmfrmucastmbss: 16
rxcfrmucast: 745
rxrtsucast: 269
rxctsucast: 311
rxackucast: 38
rxdfrmocast: 21
rxmfrmocast: 16
rxcfrmocast: 7664
rxrtsocast: 379
rxctsocast: 6351
rxdfrmmcast: 5
rxmfrmmcast: 141
rxcfrmmcast: 0
rxbeaconmbss: 47
rxdfrmucastobss: 0
rxbeaconobss: 55
rxrsptmout: 650
bcntxcancl: 0
rxf0ovfl: 0
rxf1ovfl: 0
rxf2ovfl: 0
txsfovfl: 0
pmqovfl: 0
rxcgprqfrm: 0
rxcgprsqovfl: 0
txcgprsfail: 0
txcgprssuc: 0
prs_timeout: 0
rxnack: 0
frmscons: 0
txnack: 0
txglitch_nack: 127
txburst: 0
bphy_rxcrsglitch: 1
phywatchdog: 0
bphy_badplcp: 0

--nextPart1987831.oYbR9djWU6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUfOZmAAoJEIHqZH0kK9IV07wP/ifzeum1hvOuEBrUJ8KnaA10
H4J5JA363B6zNQ3o4w/cZR0tw8JAX87d8xGesrndSH/8Baa535zYwWOrfj4e4OjB
CdchPnmCi1Qvv9NnPC976dFu/e7Po7iU7MFhBEvtgz6WxuqkT9pT0+WyVib+zzv6
HEoGHF7BowhcXyW4JSn4lqHNt1U1xXkr4yOpOnS/i79s7ANMH/FDiL2RRH7WW9RY
XNg4pcJBZ5BL3TOeKSr/XwZN2pNTJLYmtDZizrgb3qIMoeuSrkWukKmIhvQQAB3u
gbelV2kQcJ4lQnbbHJZ90ut3x2icQN4dnUpckxjadhirRArvPYP7gNhNRhLPJ+bo
FAtSIJL3LmwfQtYCPRi/gdW8k71bKyKa6MIovfR1TMWTXKMFPke7TfiwvRyl6kAu
W62FVlmiLN3uGlwAUYWRsiJ4MUMaSb8X6Hq/ZkG7gP75KVHvv7fgDhxUUS0uxGu+
s9LmLN3QCBsG0w5gqAfuAaMucnxQBYTVIdbhW8p16pmq/7UCowjYM6Emzoai0MN/
vLFJPEn7jKJhKNltK80FNpS7TlfPfbPUux8a7cMZSwPTBHgiNU5n6BlDaF1LEGug
Oa6Hln6pJQhDymu5KItxm9s2N6jveLH+gY42zvEjH4NFzZxc2RaPLlTLVv8BDhmv
lseBQdkBvKFfek7OxPZx
=VaLj
-----END PGP SIGNATURE-----

--nextPart1987831.oYbR9djWU6--
