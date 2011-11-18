From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Thu, 17 Nov 2011 19:32:29 -0500 (EST)
Message-ID: <20111117.193229.204248404169838998.davem@davemloft.net>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
	<20111117.160405.368943784304624880.davem@davemloft.net>
	<4EC58C89.7020906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vfalico@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab1KRAcm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 19:32:42 -0500
In-Reply-To: <4EC58C89.7020906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Thu, 17 Nov 2011 23:36:57 +0100

> Le 17/11/2011 22:04, David Miller a =E9crit :
>> From: Veaceslav Falico<vfalico@redhat.com>
>> Date: Tue, 15 Nov 2011 17:44:42 +0100
>>
>>> When changing mode via bonding's sysfs, the slaves are not initiali=
zed
>>> correctly. Forbid to change modes with slaves present to ensure tha=
t
>>> every
>>> slave is initialized correctly via bond_enslave().
>>>
>>> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
>>
>> Lots of discussion... what is the final verdict on this patch bondin=
g
>> folks?
>=20
> Now looks good to me, and as all others participants agreed at the
> beginning, I think it's good for everyone.

Great, applied, thanks everyone.
