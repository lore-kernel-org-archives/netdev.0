From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 2/4] bgmac: write mac address to hardware in ndo_set_mac_address
Date: Wed, 6 Feb 2013 15:57:42 +0100
Message-ID: <CACna6rxjOU9URdV5C0M8fGcCh9sT-s2uoM9reUgigOTLz_qUYA@mail.gmail.com>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
	<1360161900-2330-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:52146 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab3BFO5n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 09:57:43 -0500
Received: by mail-oa0-f50.google.com with SMTP id l20so1570610oag.37
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 06:57:42 -0800 (PST)
In-Reply-To: <1360161900-2330-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/6 Hauke Mehrtens <hauke@hauke-m.de>:
> The generic implementation just changes the netdev struct and does no=
t
> write the new mac address to the hardware or issues some command to d=
o
> so.

That's because generic "eth_mac_addr" allows changing MAC only when
interface is down. And we "upload" MAC address during bringing
interface up. So there wasn't any bug, it was just working that way :)

One question: how you tested if changing MAC with keeping interface up
works correctly? I just don't know if simple writes to
BGMAC_MACADDR_HIGH and BGMAC_MACADDR_LOW are enough.

If it works for you (changing MAC without stopping interface), I'm OK w=
ith that.

--=20
Rafa=C5=82
