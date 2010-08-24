From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: add meta match on receive hash
Date: Mon, 23 Aug 2010 20:44:22 -0700 (PDT)
Message-ID: <20100823.204422.85408087.davem@davemloft.net>
References: <20100823130803.7736ebfb@nehalam>
	<AANLkTik3tnSQOXSQWxX+GqcJpjnEyGuWyZhQ9sbPFYAt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, hadi@cyberus.ca, tgraf@redhat.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753979Ab0HXDoE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 23:44:04 -0400
In-Reply-To: <AANLkTik3tnSQOXSQWxX+GqcJpjnEyGuWyZhQ9sbPFYAt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 24 Aug 2010 07:25:19 +0800

> On Tue, Aug 24, 2010 at 4:08 AM, Stephen Hemminger
>> @@ -223,6 +223,11 @@ META_COLLECTOR(int_maclen)
>> =A0 =A0 =A0 =A0dst->value =3D skb->mac_len;
>> =A0}
>>
>> +META_COLLECTOR(int_rxhash)
>> +{
>> + =A0 =A0 =A0 dst->value =3D skb->rxhash;
>> +}
>=20
> How about using skb_get_rxhash instead. It returns the rxhash anyway.

Agreed.
