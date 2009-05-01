From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, resend] netconsole: take care of NETDEV_UNREGISTER
 event
Date: Fri, 01 May 2009 15:24:29 -0700 (PDT)
Message-ID: <20090501.152429.110153503.davem@davemloft.net>
References: <20090429.144420.262432582.davem@davemloft.net>
	<20090430084517.6de15689@pluto.restena.lu>
	<1241110115.938.1603.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonbons@linux-vserver.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764153AbZEAWYe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 18:24:34 -0400
In-Reply-To: <1241110115.938.1603.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Matt Mackall <mpm@selenic.com>
Date: Thu, 30 Apr 2009 11:48:35 -0500

> On Thu, 2009-04-30 at 08:45 +0200, Bruno Pr=E9mont wrote:
>> When netconsole is loaded and a network interface fades away (e.g. o=
n
>> rmmod $interface_driver_module) the rmmod remains stuck and some loc=
ks
>> are taken that prevent any additional module loading/unloading as we=
ll
>> as interface up/down changes.
>> In addition kernel logs (and console) get flooded at 10s interval wi=
th
>>=20
>> [  122.464065] unregister_netdevice: waiting for eth0 to become free=
=2E Usage count =3D 1
>> [  132.704059] unregister_netdevice: waiting for eth0 to become free=
=2E Usage count =3D 1
>>=20
>> This patch lets netconsole take NETDEV_UNREGISTER event into account
>> and release the affected interface if it was in use.
>>=20
>> Signed-off-by: Bruno Pr=E9mont <bonbons@linux-vserver.org>
>=20
> Acked-by: Matt Mackall <mpm@selenic.com>

Applied, thanks everyone.
