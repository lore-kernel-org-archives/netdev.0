From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 4.9] brcmfmac: use correct skb freeing helper when deleting flowring
Date: Tue, 27 Sep 2016 14:27:42 +0300
Message-ID: <87inthy441.fsf@kamboji.qca.qualcomm.com>
References: <20160927091428.19223-1-zajec5@gmail.com>
        <86fd0b60-0f73-484b-1788-3ec740672232@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51080 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932356AbcI0L1u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 07:27:50 -0400
In-Reply-To: <86fd0b60-0f73-484b-1788-3ec740672232@broadcom.com> (Arend Van
        Spriel's message of "Tue, 27 Sep 2016 12:05:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arend Van Spriel <arend.vanspriel@broadcom.com> writes:

> On 27-9-2016 11:14, Rafa=C5=82 Mi=C5=82ecki wrote:
>> From: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>>=20
>> Flowrings contain skbs waiting for transmission that were passed to us
>> by netif. It means we checked every one of them looking for 802.1x
>> Ethernet type. When deleting flowring we have to use freeing function
>> that will check for 802.1x type as well.
>>=20
>> Freeing skbs without a proper check was leading to counter not being
>> properly decreased. This was triggering a WARNING every time
>> brcmf_netdev_wait_pend8021x was called.
>
> Acked-by: Arend van Spriel <arend@broadcom.com>
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>> ---
>> Kalle: this isn't important enough for 4.8 as it's too late for that.
>>=20
>> I'd like to get it for 4.9 however, as this fixes bug that could lead
>> to WARNING on every add_key/del_key call. We was struggling with these
>> WARNINGs for some time and this fixes one of two problems causing them.

Ok, I'll queue this for 4.9.

> Please mark it for stable as well.

I can add that. Any ideas how old releases stable releases should this
go to?

--=20
Kalle Valo
