From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy settings
Date: Mon, 1 Jun 2015 16:53:19 -0700
Message-ID: <556CF06F.7040402@broadcom.com>
References: <20150531.171940.1635713770956335110.davem@davemloft.net>	<1433181931.6319.176.camel@decadent.org.uk>	<556CD197.8070401@broadcom.com> <20150601.144635.1116373189875340733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <ben@decadent.org.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>, <rjui@broadcom.com>,
	<sbranden@broadcom.com>, <jdzheng@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:2198 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbFAXxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 19:53:22 -0400
In-Reply-To: <20150601.144635.1116373189875340733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-01 02:46 PM, David Miller wrote:
> From: Arun Parameswaran <aparames@broadcom.com>
> Date: Mon, 1 Jun 2015 14:41:43 -0700
>=20
>> It would be nice for the 'ethtool' to be flexible to support queryin=
g
>> specific PHY irrespective of the net implementation, but that is bei=
ng
>> discussed in the other thread.
>=20
> Please stop arguing about this, it isn't valid.
>=20
> Your device is a switch, and therefore needs to be represented proper=
ly
> with the proper number of net_device objects.
>=20
> Even more importantly, the ethtool API is established and you cannot
> change these semantics without potentially breaking lots of applicati=
ons
> and libraries out there.
>=20
> Your change is reverted, and I will absolutely not entertain any
> attempt to again change the semantics of this ethtool operation.
>=20
> Thanks.
>=20
I apologize if the patch broke any conventions, it was not my intend. I
understand the implications on other programs that use the interface.

Just so that I don=92t make this mistake in the future and to understan=
d this
better, does this mean that the 'phyad' parameter specified in the
'ethtool' command line is ignored ?

Thanks
Arun
