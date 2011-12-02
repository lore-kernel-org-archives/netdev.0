From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] forcedeath: Fix bql support for forcedeath
Date: Fri, 02 Dec 2011 12:39:23 -0500 (EST)
Message-ID: <20111202.123923.112506974906466656.davem@davemloft.net>
References: <igorm@etf.rs>
	<1322819300-14330-1-git-send-email-igorm@etf.rs>
	<1322822803.2607.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757189Ab1LBRjb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 12:39:31 -0500
In-Reply-To: <1322822803.2607.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2011 11:46:43 +0100

> Le vendredi 02 d=E9cembre 2011 =E0 10:48 +0100, igorm@etf.rs a =E9cri=
t :
>> From: Igor Maravic <igorm@etf.rs>
>>=20
>> Moved netdev_completed_queue() out of while loop in function nv_tx_d=
one_optimized().
>> Because this function was in while loop,
>> BUG_ON(count > dql->num_queued - dql->num_completed)
>> was hit in dql_completed().
>>=20
>> Signed-off-by: Igor Maravic <igorm@etf.rs>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
