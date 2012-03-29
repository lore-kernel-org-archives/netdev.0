From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 0/6] net/mlx4_en: DCB QoS support
Date: Thu, 29 Mar 2012 05:14:06 +0200
Message-ID: <1332990846.3402.5.camel@edumazet-laptop>
References: <1332860951-23042-1-git-send-email-amirv@mellanox.com>
	 <CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59629 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049Ab2C2DOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 23:14:12 -0400
Received: by eaaq12 with SMTP id q12so547213eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 20:14:10 -0700 (PDT)
In-Reply-To: <CAJZOPZLLJdQX4i_WhV8Bo5UHaxndFDwf873n8ZTCPqXq7JrMiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 mars 2012 =C3=A0 00:21 +0200, Or Gerlitz a =C3=A9crit :

> For the ratelimit Eric D. provided feedback and it was implemented
> along his suggestion,


My suggestion was exactly the following :

/sys/class/net/eth2/qos/0/ratelimit
=2E..
/sys/class/net/eth2/qos/7/ratelimit

> and now John and Ben have other suggestions,

I dont think so.

Amir provided in V2 something that was not what I suggested.

/sys/class/net/eth2/ratelimit/tc0
=2E..
/sys/class/net/eth2/ratelimit/tc7


And this is where John, Ben were complaining.

[ Obviously I totally agree with them ]
