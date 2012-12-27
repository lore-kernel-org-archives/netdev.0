From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 27 Dec 2012 01:45:24 +0100
Message-ID: <CACna6rydhYcBZnRpz2PD5S=UfjQJ5xqkY=_+Y9BeOt-ENQqc3w@mail.gmail.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
	<20121226231721.GA8243@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:36037 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2L0Ap2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 19:45:28 -0500
Received: by mail-we0-f180.google.com with SMTP id t57so4180339wey.11
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 16:45:24 -0800 (PST)
In-Reply-To: <20121226231721.GA8243@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your comments, I'll improve the driver/patch.

2012/12/27 Francois Romieu <romieu@fr.zoreil.com>:
>> +     struct device *dma_dev =3D bgmac->core->dma_dev;
>> +     struct bgmac_dma_desc *dma_desc;
>> +     struct bgmac_slot_info *slot;
>> +     struct sk_buff *skb, *new_skb;
>> +     struct bgmac_rx_header *rx;
>> +     u32 end_slot;
>> +     u16 len, flags;
>> +     int handled =3D 0;
>
> The scope of several variables can be reduced as well.

I'm not 100% if I understand... Do you mean I should declare variables
inside "while" loop when possible? I couldn't find suggestions about
anywhere in Documentation, so please give me an extra work of
explanation :)

--=20
Rafa=C5=82
