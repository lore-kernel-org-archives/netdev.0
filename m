From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Multiple DSA switch on shared MII
Date: Tue, 25 Nov 2014 21:22:39 -0800
Message-ID: <CAGVrzcaG_uYpmmgC252ObHJ9Cmt91-BUtB3uOfPJHV6RhkRU1Q@mail.gmail.com>
References: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Rajib Karmakar <rajibkit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:54764 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaKZFXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:23:21 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so1944832iec.24
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:23:20 -0800 (PST)
In-Reply-To: <CAOi_9k8NwpVFxg=9VOagVt3m6hn2uLKuCZ_0-+4PciJNRWuTmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-11-25 20:52 GMT-08:00 Rajib Karmakar <rajibkit@gmail.com>:
> Hello,
>
> I am developing a DSA driver for Marvell 6172 and need to create 2 dsa
> switch chip (one for WAN and one for LAN).

This is not typically how it is designed to work, you would register
one dsa switch chip with the ports assignment in this data structure.
Right now, DSA does not support a dual Ethernet MAC configuration,
although you could probably do per-port VLAN membership and create two
default VLANs to allow that.

>
> My device has 2 MACs and one shared mii_bus. I have added two
> dsa_platform_data structures and registered them but cannot probe as
> dsa_probe tries mdio_register() on the same bus and fails.
>
> Is it possible to create two DSA switch on same (shared) mii?

Not in its current form, and I am not exactly sure how we would support that.

>
> Regards,
> Rajib
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
