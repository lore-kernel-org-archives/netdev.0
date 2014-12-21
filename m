From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Dec 2014 15:13:50 +0100
Message-ID: <5496D59E.5030601@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <549699D9.2060106@msgid.tls.msk.ru> <54969D18.3060000@broadcom.com> <141935691.MGh8oJCUVD@fuchs>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	"brcm80211 development" <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:58206 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbaLUONy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 09:13:54 -0500
In-Reply-To: <141935691.MGh8oJCUVD@fuchs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 15:08, Maximilian Engelhardt wrote:
> On Sunday 21 December 2014 11:12:40 Arend van Spriel wrote:
>> On 12/21/14 10:58, Michael Tokarev wrote:
>>> 16.12.2014 19:51, Arend van Spriel wrote:
>>>> Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please
>>>> remove that call as it causes endless recursion and eventually reboot.>
>>> Ok, that was easy.  Now it loads, but wifi link still
>>> does not work, stalling as before.  What we're looking
>>> at now?
>>
>> The patch is just to provide me with extra bt-coex related information
>> in the kernel log. So if you can provide that to me I have to info
>> needed to look in the proprietary code base to determine what is missing.
>>
>> Regards,
>> Arend
>
> Hi Arend,
>
> here is the output from my card:

Thanks. It shows you have have the same bt-coex version as Michael. I am 
not familiar with bluetooth side of things. Are you both using bluetooth 
on 4313?

Regards,
Arend

> [ 5167.720041] cfg80211: Calling CRDA to update world regulatory domain
> [ 5167.737243] bcma: bus0: Found chip with id 0x4313, rev 0x01 and package 0x08
> [ 5167.737271] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x24, class 0x0)
> [ 5167.737290] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x18, class 0x0)
> [ 5167.737324] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x11, class 0x0)
> [ 5167.737407] bcma: bus0: Found rev 8 PMU (capabilities 0x084C3008)
> [ 5167.737417] bcma: bus0: SPROM offset 0x830
> [ 5167.739392] bcma: bcmasprom:
> [ 5167.739396] bcma:
> 	
> [ 5167.739400] bcma: 2801
> [ 5167.739402] bcma: 0000
> [ 5167.739404] bcma: 0608
> [ 5167.739405] bcma: 14E4
> [ 5167.739408] bcma: 0070
> [ 5167.739409] bcma: EDBE
> [ 5167.739411] bcma: 0000
> [ 5167.739412] bcma: 2BC4
> [ 5167.739414] bcma: 2A64
> [ 5167.739416] bcma: 2964
> [ 5167.739417] bcma:
> 	
> [ 5167.739419] bcma: 2C64
> [ 5167.739421] bcma: 3CE7
> [ 5167.739422] bcma: 46FF
> [ 5167.739424] bcma: 47FF
> [ 5167.739425] bcma: 0C00
> [ 5167.739427] bcma: 0820
> [ 5167.739429] bcma: 0030
> [ 5167.739430] bcma: 1002
> [ 5167.739432] bcma: 9F28
> [ 5167.739434] bcma: 5D44
> [ 5167.739435] bcma:
> 	
> [ 5167.739438] bcma: 8080
> [ 5167.739439] bcma: 1D8F
> [ 5167.739441] bcma: 0032
> [ 5167.739442] bcma: 0100
> [ 5167.739444] bcma: DF00
> [ 5167.739445] bcma: 71F5
> [ 5167.739447] bcma: 8400
> [ 5167.739448] bcma: 0083
> [ 5167.739450] bcma: 8500
> [ 5167.739452] bcma: 2010
> [ 5167.739453] bcma:
> 	
> [ 5167.739455] bcma: 0001
> [ 5167.739457] bcma: 0000
> [ 5167.739458] bcma: 0000
> [ 5167.739460] bcma: 0000
> [ 5167.739461] bcma: 0000
> [ 5167.739463] bcma: 0000
> [ 5167.739464] bcma: 0000
> [ 5167.739466] bcma: 0000
> [ 5167.739467] bcma: 0000
> [ 5167.739469] bcma: 0000
> [ 5167.739470] bcma:
> 	
> [ 5167.739473] bcma: 0000
> [ 5167.739474] bcma: 0000
> [ 5167.739476] bcma: 1008
> [ 5167.739477] bcma: 0305
> [ 5167.739479] bcma: 0000
> [ 5167.739480] bcma: 0000
> [ 5167.739482] bcma: 0000
> [ 5167.739484] bcma: 0000
> [ 5167.739485] bcma: 4727
> [ 5167.739487] bcma: 8000
> [ 5167.739488] bcma:
> 	
> [ 5167.739490] bcma: 0002
> [ 5167.739492] bcma: 0000
> [ 5167.739493] bcma: 1F30
> [ 5167.739495] bcma: 1800
> [ 5167.739496] bcma: 0000
> [ 5167.739498] bcma: 0000
> [ 5167.739499] bcma: 0000
> [ 5167.739501] bcma: 0000
> [ 5167.739502] bcma: 0000
> [ 5167.739504] bcma: 0000
> [ 5167.739505] bcma:
> 	
> [ 5167.739508] bcma: 0000
> [ 5167.739509] bcma: 0000
> [ 5167.739511] bcma: 0000
> [ 5167.739512] bcma: 0000
> [ 5167.739514] bcma: 5372
> [ 5167.739515] bcma: 1109
> [ 5167.739517] bcma: 2201
> [ 5167.739519] bcma: 0040
> [ 5167.739520] bcma: 0884
> [ 5167.739522] bcma: 0000
> [ 5167.739523] bcma:
> 	
> [ 5167.739525] bcma: C014
> [ 5167.739526] bcma: 3DC1
> [ 5167.739528] bcma: 809D
> [ 5167.739530] bcma: 5856
> [ 5167.739531] bcma: 0001
> [ 5167.739533] bcma: FFFF
> [ 5167.739534] bcma: 83FF
> [ 5167.739536] bcma: FFFF
> [ 5167.739537] bcma: 0003
> [ 5167.739539] bcma: 0202
> [ 5167.739540] bcma:
> 	
> [ 5167.739543] bcma: FFFF
> [ 5167.739544] bcma: 0011
> [ 5167.739546] bcma: 017A
> [ 5167.739547] bcma: 0000
> [ 5167.739549] bcma: 0000
> [ 5167.739550] bcma: 0000
> [ 5167.739552] bcma: 0000
> [ 5167.739553] bcma: 0201
> [ 5167.739555] bcma: 0000
> [ 5167.739556] bcma: 7800
> [ 5167.739558] bcma:
> 	
> [ 5167.739559] bcma: 01FF
> [ 5167.739561] bcma: E398
> [ 5167.739563] bcma: 0008
> [ 5167.739564] bcma: 0000
> [ 5167.739566] bcma: 0000
> [ 5167.739568] bcma: 0000
> [ 5167.739569] bcma: 0044
> [ 5167.739571] bcma: 2400
> [ 5167.739572] bcma: FCF7
> [ 5167.739574] bcma: 0089
> [ 5167.739575] bcma:
> 	
> [ 5167.739578] bcma: 0000
> [ 5167.739579] bcma: 0000
> [ 5167.739581] bcma: 0000
> [ 5167.739582] bcma: 0000
> [ 5167.739584] bcma: 0000
> [ 5167.739585] bcma: 0000
> [ 5167.739587] bcma: 0000
> [ 5167.739588] bcma: 0000
> [ 5167.739590] bcma: 0000
> [ 5167.739591] bcma: 0000
> [ 5167.739593] bcma:
> 	
> [ 5167.739594] bcma: 0000
> [ 5167.739596] bcma: 0000
> [ 5167.739597] bcma: 0048
> [ 5167.739599] bcma: FED2
> [ 5167.739600] bcma: 15D9
> [ 5167.739602] bcma: FAC6
> [ 5167.739604] bcma: 0000
> [ 5167.739605] bcma: 0000
> [ 5167.739607] bcma: 0000
> [ 5167.739608] bcma: 0000
> [ 5167.739610] bcma:
> 	
> [ 5167.739612] bcma: 0000
> [ 5167.739614] bcma: 0000
> [ 5167.739615] bcma: 0000
> [ 5167.739617] bcma: 0000
> [ 5167.739618] bcma: 0000
> [ 5167.739620] bcma: 0000
> [ 5167.739622] bcma: 0000
> [ 5167.739623] bcma: 0000
> [ 5167.739625] bcma: 0000
> [ 5167.739626] bcma: 0000
> [ 5167.739627] bcma:
> 	
> [ 5167.739629] bcma: 0000
> [ 5167.739631] bcma: 0000
> [ 5167.739632] bcma: 0000
> [ 5167.739634] bcma: 0000
> [ 5167.739635] bcma: 0000
> [ 5167.739637] bcma: 0000
> [ 5167.739638] bcma: 0000
> [ 5167.739640] bcma: 0000
> [ 5167.739641] bcma: 0000
> [ 5167.739643] bcma: 0000
> [ 5167.739644] bcma:
> 	
> [ 5167.739647] bcma: 0000
> [ 5167.739648] bcma: 0000
> [ 5167.739650] bcma: 0000
> [ 5167.739651] bcma: 0000
> [ 5167.739653] bcma: 0000
> [ 5167.739654] bcma: 0000
> [ 5167.739656] bcma: 0000
> [ 5167.739657] bcma: 0000
> [ 5167.739659] bcma: 0000
> [ 5167.739660] bcma: 0000
> [ 5167.739662] bcma:
> 	
> [ 5167.739663] bcma: 0000
> [ 5167.739665] bcma: 0000
> [ 5167.739666] bcma: 0000
> [ 5167.739668] bcma: 0000
> [ 5167.739669] bcma: 0000
> [ 5167.739671] bcma: 0000
> [ 5167.739672] bcma: 0000
> [ 5167.739674] bcma: 0000
> [ 5167.739676] bcma: 0000
> [ 5167.739677] bcma: 0000
> [ 5167.739679] bcma:
> 	
> [ 5167.739681] bcma: 0000
> [ 5167.739682] bcma: 1111
> [ 5167.739684] bcma: 1111
> [ 5167.739686] bcma: 0000
> [ 5167.739687] bcma: 0000
> [ 5167.739689] bcma: 0000
> [ 5167.739690] bcma: 0000
> [ 5167.739692] bcma: 0000
> [ 5167.739693] bcma: 0000
> [ 5167.739695] bcma: 2222
> [ 5167.739696] bcma:
> 	
> [ 5167.739698] bcma: 3222
> [ 5167.739700] bcma: 0000
> [ 5167.739701] bcma: 0000
> [ 5167.739703] bcma: 0000
> [ 5167.739704] bcma: 0000
> [ 5167.739706] bcma: 0000
> [ 5167.739707] bcma: 0000
> [ 5167.739709] bcma: 0000
> [ 5167.739710] bcma: 0000
> [ 5167.739712] bcma: 0000
> [ 5167.739713] bcma:
> 	
> [ 5167.739716] bcma: 0000
> [ 5167.739717] bcma: 0000
> [ 5167.739719] bcma: 0000
> [ 5167.739720] bcma: 0000
> [ 5167.739722] bcma: 0000
> [ 5167.739723] bcma: 0000
> [ 5167.739725] bcma: 0000
> [ 5167.739726] bcma: 0000
> [ 5167.739728] bcma: 0000
> [ 5167.739729] bcma: 0000
> [ 5167.739731] bcma:
> 	
> [ 5167.739732] bcma: 0000
> [ 5167.739734] bcma: 0000
> [ 5167.739735] bcma: 0000
> [ 5167.739737] bcma: 0000
> [ 5167.739738] bcma: 0000
> [ 5167.739740] bcma: 0000
> [ 5167.739741] bcma: 0000
> [ 5167.739743] bcma: 0000
> [ 5167.739744] bcma: 0000
> [ 5167.739746] bcma: 0000
> [ 5167.739748] bcma:
> 	
> [ 5167.739750] bcma: 0000
> [ 5167.739751] bcma: 0000
> [ 5167.739753] bcma: 0000
> [ 5167.739755] bcma: 0000
> [ 5167.739756] bcma: 0000
> [ 5167.739758] bcma: 0000
> [ 5167.739759] bcma: 0000
> [ 5167.739761] bcma: 0000
> [ 5167.739762] bcma: 0000
> [ 5167.739764] bcma: 0000
> [ 5167.739765] bcma:
> 	
> [ 5167.739767] bcma: 0000
> [ 5167.739768] bcma: 0000
> [ 5167.739770] bcma: 0000
> [ 5167.739772] bcma: 0000
> [ 5167.739773] bcma: 0000
> [ 5167.739775] bcma: 0000
> [ 5167.739776] bcma: 0000
> [ 5167.739778] bcma: 0000
> [ 5167.739779] bcma: 0000
> [ 5167.739782] bcma: bus0: Found SPROM revision 8
> [ 5167.752730] bcma: bus0: GPIO driver not activated
> [ 5167.752738] bcma: bus0: Bus registered
> [ 5167.765209] brcmsmac bcma0:0: mfg 4bf core 812 rev 24 class 0 irq 17
> [ 5167.765319] bcma: bus0: Switched to core: 0x812
> [ 5167.766135] brcmsmac bcma0:0: hardware: SECI
> [ 5167.766559] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
> [ 5167.786115] cfg80211: World regulatory domain updated:
> [ 5167.786128] cfg80211:  DFS Master region: unset
> [ 5167.786131] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
> [ 5167.786137] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.786141] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.786144] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.786148] cfg80211:   (5170000 KHz - 5250000 KHz @ 160000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.786152] cfg80211:   (5250000 KHz - 5330000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
> [ 5167.786155] cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
> [ 5167.786159] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.786162] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
> [ 5167.794806] cfg80211: Calling CRDA for country: DE
> [ 5167.810110] cfg80211: Regulatory domain changed to country: DE
> [ 5167.810122] cfg80211:  DFS Master region: ETSI
> [ 5167.810125] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
> [ 5167.810131] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.810134] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
> [ 5167.810139] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz), (N/A, 2000 mBm), (0 s)
> [ 5167.810142] cfg80211:   (5470000 KHz - 5725000 KHz @ 80000 KHz), (N/A, 2698 mBm), (0 s)
> [ 5167.810146] cfg80211:   (57240000 KHz - 65880000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)
>
>
> Greetings,
> Maxi
