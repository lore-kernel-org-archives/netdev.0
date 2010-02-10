From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [net-next PATCH v2 2/3] net: TCP thin linear timeouts
Date: Wed, 10 Feb 2010 14:49:14 +0100
Message-ID: <4B72B95A.10402@simula.no>
References: <4B701EE2.1000006@simula.no> <1265697119.4236.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBK?= =?UTF-8?B?w6RydmluZW4=?=
	<ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:58125 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab0BJNtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 08:49:16 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NfCwN-0001Lo-3o
	for netdev@vger.kernel.org; Wed, 10 Feb 2010 14:49:15 +0100
In-Reply-To: <1265697119.4236.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/09/2010 07:31 AM, Eric Dumazet wrote:
> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:25 +0100, Andreas Petlund a =C3=
=A9crit :
>> =20
>> +	case TCP_THIN_LT:
>> +		if (val)
>> +			tp->thin_lt =3D 1;
>> +		break;
>> +
>=20
> Why not allowing user to clear thin_lt ?
>=20
>=20

That is a very good point. I will fix that in the next iteration,
as well as error handling for out of bounds values.

Best regards,
Andreas
