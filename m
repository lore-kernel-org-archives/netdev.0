From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Mon, 12 Dec 2016 11:22:59 -0500
Message-ID: <87d1gx9kws.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37238 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbcLLQXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:23:05 -0500
In-Reply-To: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Volodymyr,

Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com> writes:

> +struct pvec_tbl_entry {
> +        struct hlist_node entry;
> +        u32 key_crc32; /* key */
> +        u16 pvec;
> +        struct pvec_tbl_key {
> +                u8 addr[ETH_ALEN];
> +                u16 fid;
> +        } key;
> +};
> +
>  struct mv88e6xxx_atu_entry {
>  	u16	fid;
>  	u8	state;

Also, if we were to cache some values in mv88e6xxx, I'd use the existing
structures which match the hardware definition. Easier to understand.

mv88e6xxx_atu_entry already represents an ATU entry with its port
vector, FID, MAC address and more. Do you think it can be used here?

Thanks,

        Vivien
