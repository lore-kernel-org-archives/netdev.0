From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 2/4] bgmac: write mac address to hardware in ndo_set_mac_address
Date: Wed, 06 Feb 2013 16:17:33 +0100
Message-ID: <5112740D.2000402@hauke-m.de>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de> <1360161900-2330-3-git-send-email-hauke@hauke-m.de> <CACna6rxjOU9URdV5C0M8fGcCh9sT-s2uoM9reUgigOTLz_qUYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34831 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab3BFPRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 10:17:41 -0500
In-Reply-To: <CACna6rxjOU9URdV5C0M8fGcCh9sT-s2uoM9reUgigOTLz_qUYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2013 03:57 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2013/2/6 Hauke Mehrtens <hauke@hauke-m.de>:
>> The generic implementation just changes the netdev struct and does n=
ot
>> write the new mac address to the hardware or issues some command to =
do
>> so.
>=20
> That's because generic "eth_mac_addr" allows changing MAC only when
> interface is down. And we "upload" MAC address during bringing
> interface up. So there wasn't any bug, it was just working that way :=
)
>=20
> One question: how you tested if changing MAC with keeping interface u=
p
> works correctly? I just don't know if simple writes to
> BGMAC_MACADDR_HIGH and BGMAC_MACADDR_LOW are enough.
>=20
> If it works for you (changing MAC without stopping interface), I'm OK=
 with that.
>=20
Yes that works in promisc and non promisc mode, I did this while pingin=
g
the device and I had no package lose.

Hauke
