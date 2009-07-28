From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Tue, 28 Jul 2009 07:38:53 +0200
Message-ID: <4A6E8EED.8050600@gmail.com>
References: <4A6D7285.9080909@gmail.com> <b5ddba180907270334m4bc4e968m85c16ea4756c3f5d@mail.gmail.com> <20090727131357.9561.39720.stgit@jazzy.zrh.corp.google.com> <20090727.114845.177925839.davem@davemloft.net> <20090728001926.GA20230@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, heder@google.com,
	netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org,
	malcolm@loadbalancer.org, linux-kernel@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39862 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbZG1FjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 01:39:09 -0400
In-Reply-To: <20090728001926.GA20230@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman a =E9crit :
>=20
> Surprisingly its a very common question amongst users,
> because they want to know how much memory they need.
> It is of course all a bit silly, because the amount of
> memory used by the connection table is usually very small,
> but people still ask.
>=20

If SLUB is used=20

$ cat /sys/kernel/slab/ip_vs_conn/object_size

If SLAB is used, take fourth column of :

$ grep ip_vs_conn /proc/slabinfo

BTW these take into account L1 cache size alignment
