From: Nick Kossifidis <mickflemm@gmail.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Tue, 17 May 2011 20:14:34 +0300
Message-ID: <BANLkTi=8ZRUVWn3FLAMtPh=4yY1F0k6i9w__47969.8511459448$1305652506$gmane$org@mail.gmail.com>
References: <20110504153819.GA4551@thinkpad-t410>
	<20110504172716.GC18541@tuxdriver.com>
	<20110504192639.GB4551@thinkpad-t410>
	<BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
	<20110505135207.GA13727@thinkpad-t410>
	<BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
	<20110509070230.GA20458@thinkpad-t410>
	<20110517165720.GB9258@thinkpad-t410>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Nick Kossifidis <mickflemm@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@b
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:44315 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755945Ab1EQROf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 13:14:35 -0400
In-Reply-To: <20110517165720.GB9258@thinkpad-t410>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/17 Seth Forshee <seth.forshee@canonical.com>:
> On Mon, May 09, 2011 at 09:02:30AM +0200, Seth Forshee wrote:
>> On Thu, May 05, 2011 at 05:30:42PM +0300, Nick Kossifidis wrote:
>> > Hmm I don't see any errors from reset/phy code, can you disable
>> > Network Manager/wpa-supplicant and test connection on an open network
>> > using iw ? It 'll give us a better picture...
>> >
>> > If iw doesn't return any scan results we are probably hitting a PHY/RF
>> > error specific to your device (not all vendors follow the reference
>> > design). Maybe we should follow a blacklist/whitelist approach for
>> > this feature.
>>
>> I got the results back from my tester. He was able to get scan results,
>> but it took multiple tries and the direct probe failures appear in the
>> log. He didn't enable ATH5K_DEBUG_RESET this time; let me know if you
>> need that and I'll request he retest with the extra debug logs enabled.
>
> I got some more feedback. Most of the time iw does not get scan results,
> but even when it does connecting to the AP isn't always successful. The
> tester did note that he doesn't seem to have any trouble if his machine
> is within a few feet of his AP. Let me know if you'd like something else
> tested.
>
> I noticed that bugzilla #31922 (ath5k: Decreased throughput in IBSS or
> 802.11n mode) is also fixed by reverting 8aec7af9. It seems like the
> synth-only channel changes are resulting in poor connection quality.
> Maybe that patch needs to be reverted?
>
> Thanks,
> Seth
>
>

http://www.kernel.org/pub/linux/kernel/people/mickflemm/01-fast-chan-switch-modparm

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
