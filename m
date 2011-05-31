From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [ath5k-devel] ath5k regression associating with APs in 2.6.38
Date: Tue, 31 May 2011 19:31:07 +0200
Message-ID: <4DE525DB.1000908@openwrt.org>
References: <20110504153819.GA4551@thinkpad-t410>	<20110504172716.GC18541@tuxdriver.com>	<20110504192639.GB4551@thinkpad-t410>	<BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>	<20110505135207.GA13727@thinkpad-t410>	<BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>	<20110509070230.GA20458@thinkpad-t410>	<20110517165720.GB9258@thinkpad-t410> <BANLkTi=8ZRUVWn3FLAMtPh=4yY1F0k6i9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Kossifidis <mickflemm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:37919 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757873Ab1EaRba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 13:31:30 -0400
In-Reply-To: <BANLkTi=8ZRUVWn3FLAMtPh=4yY1F0k6i9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-05-17 7:14 PM, Nick Kossifidis wrote:
> 2011/5/17 Seth Forshee<seth.forshee@canonical.com>:
>>  On Mon, May 09, 2011 at 09:02:30AM +0200, Seth Forshee wrote:
>>>  On Thu, May 05, 2011 at 05:30:42PM +0300, Nick Kossifidis wrote:
>>>  >  Hmm I don't see any errors from reset/phy code, can you disable
>>>  >  Network Manager/wpa-supplicant and test connection on an open network
>>>  >  using iw ? It 'll give us a better picture...
>>>  >
>>>  >  If iw doesn't return any scan results we are probably hitting a PHY/RF
>>>  >  error specific to your device (not all vendors follow the reference
>>>  >  design). Maybe we should follow a blacklist/whitelist approach for
>>>  >  this feature.
>>>
>>>  I got the results back from my tester. He was able to get scan results,
>>>  but it took multiple tries and the direct probe failures appear in the
>>>  log. He didn't enable ATH5K_DEBUG_RESET this time; let me know if you
>>>  need that and I'll request he retest with the extra debug logs enabled.
>>
>>  I got some more feedback. Most of the time iw does not get scan results,
>>  but even when it does connecting to the AP isn't always successful. The
>>  tester did note that he doesn't seem to have any trouble if his machine
>>  is within a few feet of his AP. Let me know if you'd like something else
>>  tested.
>>
>>  I noticed that bugzilla #31922 (ath5k: Decreased throughput in IBSS or
>>  802.11n mode) is also fixed by reverting 8aec7af9. It seems like the
>>  synth-only channel changes are resulting in poor connection quality.
>>  Maybe that patch needs to be reverted?
>>
>>  Thanks,
>>  Seth
>>
>>
>
> http://www.kernel.org/pub/linux/kernel/people/mickflemm/01-fast-chan-switch-modparm
Disabling fast channel change also fixed a reproducible crash on 
Broadcom based MIPS boards with some cards (AR2413, I think).

- Felix
