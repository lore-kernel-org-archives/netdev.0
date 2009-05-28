From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: changing the qdisc class speed rate
Date: Wed, 27 May 2009 22:21:58 -0700
Message-ID: <20090527222158.42f71e28@nehalam>
References: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Piotr =?UTF-8?B?RHVzennFhHNraQ==?= <regis44@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37282 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbZE1FWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 01:22:02 -0400
In-Reply-To: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 May 2009 07:12:33 +0200
Piotr Duszy=C5=84ski <regis44@gmail.com> wrote:

> Hi everyone,
>=20
> I am trying to change the rate parameter of HTB class by using this =20
> code from within one of my functions :
>=20
>    struct htb_class *cl;
>    cl=3Dhtb_find(number,q);
>=20
>    cl->rate->rate.rate =3D NEW_RATE_VALUE;
>=20
>    TC shows the correct values, but the traffic rate doesn't change a=
 =20
> bit.
>    Does anyone have any idea what am I doing wrong ? Maybe there woul=
d =20
> be a faster way by sending a netlink  message ?
>=20
> Piotrek

HTB uses a rate table, so if you want the rate to change, you will need=
 to change the
table as well.
