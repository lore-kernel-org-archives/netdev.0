From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 10:57:38 -0800 (PST)
Message-ID: <20101129.105738.59675582.davem@davemloft.net>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
	<4CF3EBF2.5060308@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dshwatrz@gmail.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750908Ab0K2S5M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 13:57:12 -0500
In-Reply-To: <4CF3EBF2.5060308@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Mon, 29 Nov 2010 20:07:46 +0200

> On 01/-10/-28163 09:59 PM, David Shwatrz wrote:
>> Hi,
>>  The patch removes unused member in xfrm_encap_tmpl.
>>=20
>> Regards,
>> David Shwartz
>>=20
>>=20
>> Signed-off-by: David Shwartz <dshwatrz@gmail.com>
>>=20
>>=20
>> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
>> index b971e38..7312707 100644
>> --- a/include/linux/xfrm.h
>> +++ b/include/linux/xfrm.h
>> @@ -235,7 +235,6 @@ struct xfrm_encap_tmpl {
>>  	__u16		encap_type;
>>  	__be16		encap_sport;
>>  	__be16		encap_dport;
>> -	xfrm_address_t	encap_oa;
>>  };
>> =20
>>  /* AEVENT flags  */
>=20
> struct xfrm_encap_tmpl is exposed to userland via netlink. This would
> break ABI.

RIght.
