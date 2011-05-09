From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Mon, 9 May 2011 09:02:30 +0200
Message-ID: <20110509070230.GA20458@thinkpad-t410>
References: <20110504153819.GA4551@thinkpad-t410>
 <20110504172716.GC18541@tuxdriver.com>
 <20110504192639.GB4551@thinkpad-t410>
 <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
 <20110505135207.GA13727@thinkpad-t410>
 <BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Kossifidis <mickflemm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2011 at 05:30:42PM +0300, Nick Kossifidis wrote:
> Hmm I don't see any errors from reset/phy code, can you disable
> Network Manager/wpa-supplicant and test connection on an open network
> using iw ? It 'll give us a better picture...
> 
> If iw doesn't return any scan results we are probably hitting a PHY/RF
> error specific to your device (not all vendors follow the reference
> design). Maybe we should follow a blacklist/whitelist approach for
> this feature.

I got the results back from my tester. He was able to get scan results,
but it took multiple tries and the direct probe failures appear in the
log. He didn't enable ATH5K_DEBUG_RESET this time; let me know if you
need that and I'll request he retest with the extra debug logs enabled.


[   25.070218] ath5k 0000:06:02.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[   25.070290] ath5k 0000:06:02.0: registered as 'phy0'
[   25.830368] ath: EEPROM regdomain: 0x63
[   25.830372] ath: EEPROM indicates we should expect a direct regpair map
[   25.830376] ath: Country alpha2 being used: 00
[   25.830378] ath: Regpair used: 0x63
[   25.830382] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[   25.830386] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830388] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[   25.830392] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830394] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[   25.830397] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830400] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[   25.830403] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830405] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[   25.830409] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830411] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[   25.830414] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830417] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[   25.830420] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830423] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[   25.830426] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830428] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[   25.830431] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830434] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[   25.830437] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830440] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[   25.830443] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830445] cfg80211: Updating information on frequency 2467 MHz for a 20 MHz width channel with regulatory rule:
[   25.830449] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830451] cfg80211: Updating information on frequency 2472 MHz for a 20 MHz width channel with regulatory rule:
[   25.830454] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (N/A mBi, 2000 mBm)
[   25.830457] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[   25.842012] cfg80211: Ignoring regulatory request Set by core since the driver uses its own custom regulatory domain 
[   26.048048] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   26.051154] ath5k phy0: Atheros AR2413 chip found (MAC: 0x78, PHY: 0x45)
[  133.492866] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  278.050097] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
[  278.248082] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
[  278.448111] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
[  278.648084] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
[  283.920272] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  284.120232] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  284.320074] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  284.520081] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  295.029501] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  295.228085] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  295.428086] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  295.628099] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  306.137353] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  306.336092] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  306.536097] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  306.736099] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  317.245279] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  317.444097] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  317.644111] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  317.844091] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  328.348112] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  328.548171] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  328.748109] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  328.948095] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  339.453369] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  339.652085] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  339.852082] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  340.052092] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  344.316878] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
[  344.516064] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
[  344.716125] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
[  344.916101] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
[  355.421554] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
[  355.620092] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
[  355.820642] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
[  356.020054] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
[  366.521629] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
[  366.720085] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
[  366.920080] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
[  367.120367] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
[  433.347401] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  468.143619] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 1/3)
[  468.340073] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 2/3)
[  468.540069] wlan0: direct probe to c2:3f:0e:b9:f3:b3 (try 3/3)
[  468.740069] wlan0: direct probe to c2:3f:0e:b9:f3:b3 timed out
[  482.093842] wlan0: authenticate with c2:3f:0e:b9:f3:b3 (try 1)
[  482.095325] wlan0: authenticated
[  482.095384] wlan0: associate with c2:3f:0e:b9:f3:b3 (try 1)
[  482.097657] wlan0: RX AssocResp from c2:3f:0e:b9:f3:b3 (capab=0x401 status=0 aid=1)
[  482.097666] wlan0: associated
[  482.099748] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  492.416050] wlan0: no IPv6 routers present
[  547.281613] wlan0: deauthenticating from c2:3f:0e:b9:f3:b3 by local choice (reason=3)
[  547.281973] cfg80211: All devices are disconnected, going to restore regulatory settings
[  547.281984] cfg80211: Restoring regulatory settings
[  547.283060] cfg80211: Calling CRDA to update world regulatory domain
[  547.311427] cfg80211: Ignoring regulatory request Set by core since the driver uses its own custom regulatory domain 
[  547.311446] cfg80211: World regulatory domain updated:
[  547.311451] cfg80211:     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[  547.311461] cfg80211:     (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[  547.311469] cfg80211:     (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[  547.311477] cfg80211:     (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[  547.311484] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[  547.311492] cfg80211:     (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
