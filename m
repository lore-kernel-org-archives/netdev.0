From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netfilter: fix the race when initializing
 nf_ct_expect_hash_rnd
Date: Thu, 06 Jan 2011 11:22:34 -0800 (PST)
Message-ID: <20110106.112234.115929607.davem@davemloft.net>
References: <1294237403-15616-1-git-send-email-xiaosuo@gmail.com>
	<1294250598.10633.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048Ab1AFTWD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 14:22:03 -0500
In-Reply-To: <1294250598.10633.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Jan 2011 19:03:18 +0100

> Le mercredi 05 janvier 2011 =E0 22:23 +0800, Changli Gao a =E9crit :
>> Since nf_ct_expect_dst_hash() may be called without nf_conntrack_loc=
k
>> locked, nf_ct_expect_hash_rnd should be initialized in the atomic wa=
y.
>>=20
>> In this patch, we use nf_conntrack_hash_rnd instead of
>> nf_ct_expect_hash_rnd.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
