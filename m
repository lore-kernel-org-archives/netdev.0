From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 0/2] Create ancient subdirectories for old
 hardware
Date: Fri, 18 Mar 2016 23:16:26 -0400 (EDT)
Message-ID: <20160318.231626.670272515350508280.davem@davemloft.net>
References: <cover.1458347329.git.joe@perches.com>
	<20160318.221153.997255526626920777.davem@davemloft.net>
	<1458354482.26915.35.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbcCSDQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 23:16:28 -0400
In-Reply-To: <1458354482.26915.35.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Fri, 18 Mar 2016 19:28:02 -0700

> On Fri, 2016-03-18 at 22:11 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Fri, 18 Mar 2016 17:33:29 -0700
>>=20
>> > Maybe something like this:
>> >=A0
>> > Old, rare, and unsupported hardware should be exposed as ancient.
>> >=A0
>> > The drivers for these ancient hardwares are generally untested wit=
h
>> > current kernels.
>>=20
>> Moving drivers has a long term maintainence cost.
>>=20
>> If they've moved into drivers/net proper, we have to maintain
>> them there forever.
>=20
> I don't doubt that.
>=20
> All files are still in drivers/net, just possibly in
> separate subdirectories for easier visibility to
> determine if changes like what were proposed for cxgb
> should actually be done or not.

You don't understand my concern, backporting patches to -stable
releases is more painful if you move the driver anywhere other
than where it has been for years.

I'm not entertaining this idea, sorry Joe.
