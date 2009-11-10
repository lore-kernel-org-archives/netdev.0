From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Tue, 10 Nov 2009 19:23:45 +0100
Message-ID: <4AF9AFB1.3080105@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.409162953@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Ed L. Cashin" <ecashin@coraid.com>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37508 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434AbZKJSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:23:45 -0500
In-Reply-To: <20091110175647.409162953@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This gets rid of another use of read_lock(&dev_base_lock) by using
> RCU. Also, it only increments the reference count of the device actua=
lly
> used rather than holding and releasing every device
>=20
> Compile tested only.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

