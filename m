From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Mon, 05 Mar 2007 09:21:30 +0100
Message-ID: <45EBD30A.4030908@cosmosbay.com>
References: <20070304.161924.55508971.davem@davemloft.net>	<45EBBF21.1000209@cosmosbay.com>	<45EBC953.30905@cosmosbay.com> <20070305.000034.74747229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50484 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbXCEIWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 03:22:08 -0500
In-Reply-To: <20070305.000034.74747229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 05 Mar 2007 08:40:03 +0100
>=20
>> Here is the second version of this patch, including missing bits spo=
ted by=20
>> Stephen. This is against net-2.6.22
>=20
> Applied, thanks a lot.
>=20
>> Note : this patch includes a bug correction in compat_sock_get_times=
tamp()
>> where a "err =3D 0;" was missing (so this syscall returned -ENOENT i=
nstead of
>> 0)
>=20
> Grrr, good spotting.  Eric can you send me a version of just this bug
> fix against 2.6.21?  I'll push that to Linus and 2.6.x-stable.

Yes I will do it. But, are your sure its really used ?

I dont know very much this compat stuff, but I found=20
compat_sock_get_timestamp() only called from net/x25/af_x25.c

I wonder how a 32 bit task on x86_64 can enter this compat code on othe=
r sockets ?

