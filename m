From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: [PATCH v3] Marvell phy: add fiber status check and configuration
 for some phys
Date: Tue, 12 Jul 2016 17:34:55 +0200
Message-ID: <2b03e18d-807c-4380-2c2c-10294cdf48d7@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
 <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
 <20160712151809.GA31432@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mo3.mail-out.ovh.net ([87.98.178.58]:44347 "EHLO
	17.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbcGLQSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:18:46 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id CA0321024418
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 17:59:07 +0200 (CEST)
In-Reply-To: <20160712151809.GA31432@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Le 12/07/2016 =E0 17:18, Andrew Lunn a =E9crit :
> Hi Charles
It's Charles-Antoine. ;)

>=20
> It is best to submit a number of smaller patches, each doing one
> thing, than a single big patch. It makes review and discussion much
> simpler.
I'm sorry, I will fix that.


> So for example, this should be a patch of its own:
>=20
>> @@ -151,6 +165,7 @@ struct marvell_hw_stat {
>> =20
>>  static struct marvell_hw_stat marvell_hw_stats[] =3D {
>>  	{ "phy_receive_errors", 0, 21, 16},
>> +	{ "phy_receive_errors_fiber", 1, 21, 16},
>>  	{ "phy_idle_errors", 0, 10, 8 },
>>  };
>=20
> I think we should also rename phy_receive_errors to
> phy_receive_errors_copper.

I agree with you. I will fix that too.
Thanks.
Charles-Antoine Couret
