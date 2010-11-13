From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next-2.6 V2] igmp: RCU conversion of in_dev->mc_list
Date: Sat, 13 Nov 2010 14:44:21 +0800
Message-ID: <20101113064421.GE3837@hack>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com> <1289489007.17691.1310.camel@edumazet-laptop> <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com> <20101112071323.GB5660@cr0.nay.redhat.com> <1289546874.17691.1774.camel@edumazet-laptop> <20101112081945.GA5949@cr0.nay.redhat.com> <1289553759.3185.1.camel@edumazet-laptop> <1289568858.3185.252.camel@edumazet-laptop> <1289571974.3185.254.camel@edumazet-laptop> <1289576810.3185.261.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44178 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab0KMGlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 01:41:19 -0500
Content-Disposition: inline
In-Reply-To: <1289576810.3185.261.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>Here is an updated version.
>
>[PATCH net-next-2.6 V2] igmp: RCU conversion of in_dev->mc_list
>
>in_dev->mc_list is protected by one rwlock (in_dev->mc_list_lock).
>
>This can easily be converted to a RCU protection.
>
>Writers hold RTNL, so mc_list_lock is removed, not replaced by a
>spinlock.

Ah, this saves much work.

>
>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>Cc: Cypher Wu <cypher.w@gmail.com>
>Cc: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>

I just did a quick look, it looks good to me.

Thanks!
