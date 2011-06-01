From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: fix typo in vlan_dev_hard_start_xmit()
Date: Wed, 01 Jun 2011 17:07:07 +0200
Message-ID: <1306940827.2890.0.camel@edumazet-laptop>
References: <4DE5FDFF.4000208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48825 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab1FAPHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 11:07:12 -0400
Received: by wwa36 with SMTP id 36so6146410wwa.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 08:07:11 -0700 (PDT)
In-Reply-To: <4DE5FDFF.4000208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 juin 2011 =C3=A0 16:53 +0800, Wei Yongjun a =C3=A9crit :
> commit 4af429d29b341bb1735f04c2fb960178ed5d52e7 (vlan: lockless
> transmit path) have a typo in vlan_dev_hard_start_xmit(), using
> u64_stats_update_begin() to end the stat update, it should be
> u64_stats_update_end().
>=20
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Good catch, Thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


