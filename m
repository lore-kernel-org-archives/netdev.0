From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock)
 usages
Date: Tue, 10 Nov 2009 10:22:10 -0800
Message-ID: <20091110102210.7540204f@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<4AF9AE66.3010303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52439 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757492AbZKJSW0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:22:26 -0500
In-Reply-To: <4AF9AE66.3010303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 19:18:14 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > The goal is to eliminate dev_base_lock completely, and just use RCU
> > and rtnl_mutex for network devices. This series gets rid of the man=
y
> > of the users of dev_base_lock just for reading.
> >=20
>=20
> Nice, but I was doing all this work Stephen... maybe I am too slow ?
>=20
> I believe you missed one of my patch (but David is traveling)
>=20
> [PATCH net-next-2.6] ipv6: speedup inet6_dump_ifinfo()
>=20
> This conflicts with your :
>=20
> [PATCH 08/10] ipv6: use RCU to walk list of network devices
>=20

Inflight conflict.

--=20
