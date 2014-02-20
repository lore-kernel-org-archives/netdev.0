From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: pull request: wireless-next 2014-02-20
Date: Thu, 20 Feb 2014 17:22:10 -0600
Message-ID: <53068E22.5050003@lwfinger.net>
References: <20140220203005.GF3657@tuxdriver.com> <20140220.172922.864207706999214682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:49328 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbaBTXWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 18:22:21 -0500
In-Reply-To: <20140220.172922.864207706999214682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2014 04:29 PM, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 20 Feb 2014 15:30:05 -0500
>
>> Please pull this batch of wireless updates intended for the 3.15
>> stream!
>>
>> For the mac80211 bits, Johannes says:
>>
>> "We have some cleanups and minor fixes as well as userspace API
>> improvements from a lot of people, extended VHT support for radiotap
>> from Emmanuel, CSA improvements from Andrei, Luca and Michal. I've a=
lso
>> included my work on hwsim to make dynamic registration of radios
>> possible."
>>
>> Along with that, we get the usual round of updates to ath9k,
>> brcmfmac, mwifiex, wcn36xx, and the ti drivers -- nothing particular=
ly
>> noteworthy, mostly just random updates and refactoring.
>>
>> Also included is a pull of the wireless tree, intended to resolve
>> some potential merge issues.
>>
>> Please let me know if there are problems!
>
> Pulled, but please address this:
>
> drivers/staging/rtl8821ae/rtl8821ae/trx.c: In function =A1rtl8821ae_r=
x_query_desc=A2:
> drivers/staging/rtl8821ae/rtl8821ae/trx.c:619:3: warning: passing arg=
ument 1 of =A1ieee80211_is_robust_mgmt_frame=A2 from incompatible point=
er type [enabled by default]
>
> I was going to do the easy transformation to the "_" prefixed variant
> but noticed that this code doesn't validate the skb length, which is
> precisely the reason why this routine now takes an skb.

David,

That staging driver is expected to be deleted in a commit to be submitt=
ed in=20
about one week. The new one will be in the regular wireless tree. The s=
taging=20
version was submitted so that there would be a driver in 3.14.

I was surprised to see this patch in John's list. It should have gone t=
hrough=20
GregKH. In fact, has has been suppressing all cleanups because the bett=
er one=20
will be available soon.

I suggest that you drop this one now. I will, however, check the new so=
urce to=20
make sure that the skb length is checked.

Thanks,

Larry
