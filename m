From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock) usages
Date: Tue, 10 Nov 2009 19:18:14 +0100
Message-ID: <4AF9AE66.3010303@gmail.com>
References: <20091110175446.280423729@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33093 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756545AbZKJSSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:18:12 -0500
In-Reply-To: <20091110175446.280423729@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The goal is to eliminate dev_base_lock completely, and just use RCU
> and rtnl_mutex for network devices. This series gets rid of the many
> of the users of dev_base_lock just for reading.
>=20

Nice, but I was doing all this work Stephen... maybe I am too slow ?

I believe you missed one of my patch (but David is traveling)

[PATCH net-next-2.6] ipv6: speedup inet6_dump_ifinfo()

This conflicts with your :

[PATCH 08/10] ipv6: use RCU to walk list of network devices

