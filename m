From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rtnetlink: rtnl_setlink() and rtnl_getlink()
 changes
Date: Thu, 22 Oct 2009 04:59:14 +0200
Message-ID: <4ADFCA82.80901@gmail.com>
References: <4ADF7633.9050208@gmail.com> <20091022064839.6b343125@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44490 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbZJVC7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 22:59:14 -0400
In-Reply-To: <20091022064839.6b343125@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Wed, 21 Oct 2009 22:59:31 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephen, do you think we could change "ip link show dev ethX" to
>> let it use rtnl_getlink() instead of rtnl_dump_ifinfo() ?
>>
>=20
> Would work, but not sure what it gains.

It takes about one second to dump the table when we have 25.000 devices
