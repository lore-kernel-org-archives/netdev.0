From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: fix typo in vlan_dev_hard_start_xmit()
Date: Wed, 01 Jun 2011 21:09:34 -0700 (PDT)
Message-ID: <20110601.210934.118116812798314878.davem@davemloft.net>
References: <4DE5FDFF.4000208@cn.fujitsu.com>
	<1306940827.2890.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab1FBEJq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:09:46 -0400
In-Reply-To: <1306940827.2890.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Jun 2011 17:07:07 +0200

> Le mercredi 01 juin 2011 =E0 16:53 +0800, Wei Yongjun a =E9crit :
>> commit 4af429d29b341bb1735f04c2fb960178ed5d52e7 (vlan: lockless
>> transmit path) have a typo in vlan_dev_hard_start_xmit(), using
>> u64_stats_update_begin() to end the stat update, it should be
>> u64_stats_update_end().
>>=20
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>=20
> Good catch, Thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.

Thanks!
