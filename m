From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Tue, 17 May 2011 11:57:20 -0500
Message-ID: <20110517165720.GB9258@thinkpad-t410>
References: <20110504153819.GA4551@thinkpad-t410>
 <20110504172716.GC18541@tuxdriver.com>
 <20110504192639.GB4551@thinkpad-t410>
 <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
 <20110505135207.GA13727@thinkpad-t410>
 <BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
 <20110509070230.GA20458@thinkpad-t410>
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
In-Reply-To: <20110509070230.GA20458@thinkpad-t410>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 09, 2011 at 09:02:30AM +0200, Seth Forshee wrote:
> On Thu, May 05, 2011 at 05:30:42PM +0300, Nick Kossifidis wrote:
> > Hmm I don't see any errors from reset/phy code, can you disable
> > Network Manager/wpa-supplicant and test connection on an open network
> > using iw ? It 'll give us a better picture...
> > 
> > If iw doesn't return any scan results we are probably hitting a PHY/RF
> > error specific to your device (not all vendors follow the reference
> > design). Maybe we should follow a blacklist/whitelist approach for
> > this feature.
> 
> I got the results back from my tester. He was able to get scan results,
> but it took multiple tries and the direct probe failures appear in the
> log. He didn't enable ATH5K_DEBUG_RESET this time; let me know if you
> need that and I'll request he retest with the extra debug logs enabled.

I got some more feedback. Most of the time iw does not get scan results,
but even when it does connecting to the AP isn't always successful. The
tester did note that he doesn't seem to have any trouble if his machine
is within a few feet of his AP. Let me know if you'd like something else
tested.

I noticed that bugzilla #31922 (ath5k: Decreased throughput in IBSS or
802.11n mode) is also fixed by reverting 8aec7af9. It seems like the
synth-only channel changes are resulting in poor connection quality.
Maybe that patch needs to be reverted?

Thanks,
Seth
