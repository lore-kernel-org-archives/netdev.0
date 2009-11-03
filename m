From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Support specifying the network namespace upon
 device creation.
Date: Tue, 03 Nov 2009 02:44:24 -0800 (PST)
Message-ID: <20091103.024424.146854177.davem@davemloft.net>
References: <m1ws28ey3k.fsf@fess.ebiederm.org>
	<20091103.020555.156050455.davem@davemloft.net>
	<4AF0031B.4060708@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbZKCKoA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 05:44:00 -0500
In-Reply-To: <4AF0031B.4060708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Nov 2009 11:16:59 +0100

> David Miller a =E9crit :
>=20
>> It can also be argued that for functions, wrapping the args is
>> worse because it makes grep output less useful.  In fact that's,
>> I believe, Linus's most recent recommendation in this area :)
>=20
> Yes, true.
>=20
> One thing I usually miss is the { next to "struct some_name" declarat=
ions,
> to ease games based on "grep"=20
>=20
> Would you accept one boring cleanup patch in include/net like followi=
ng ?

Absolutely.
