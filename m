From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 8/8] net: backlog functions rename
Date: Fri, 05 Mar 2010 13:36:41 -0800 (PST)
Message-ID: <20100305.133641.92557368.davem@davemloft.net>
References: <1267761707-15605-7-git-send-email-yi.zhu@intel.com>
	<1267761707-15605-8-git-send-email-yi.zhu@intel.com>
	<1267770735.2867.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yi.zhu@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752622Ab0CEVgV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 16:36:21 -0500
In-Reply-To: <1267770735.2867.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Mar 2010 07:32:15 +0100

> Le vendredi 05 mars 2010 =E0 12:01 +0800, Zhu Yi a =E9crit :
>> sk_add_backlog -> __sk_add_backlog
>> sk_add_backlog_limited -> sk_add_backlog
>>=20
>> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
>> ---
>>  include/net/sock.h       |    6 +++---
>>  net/core/sock.c          |    2 +-
>>  net/dccp/minisocks.c     |    2 +-
>>  net/ipv4/tcp_ipv4.c      |    2 +-
>>  net/ipv4/tcp_minisocks.c |    2 +-
>>  net/ipv4/udp.c           |    2 +-
>>  net/ipv6/tcp_ipv6.c      |    2 +-
>>  net/ipv6/udp.c           |    4 ++--
>>  net/llc/llc_c_ac.c       |    2 +-
>>  net/llc/llc_conn.c       |    2 +-
>>  net/sctp/input.c         |    4 ++--
>>  net/tipc/socket.c        |    2 +-
>>  net/x25/x25_dev.c        |    2 +-
>>  13 files changed, 17 insertions(+), 17 deletions(-)
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

All 8 patches applied to net-2.6, thanks Zhu!

=46eel free to send me a patch which adds the "__must_check"
tag to sk_add_backlog() so that any failure to check and
drop packets will be at least warned about.

Thanks!
