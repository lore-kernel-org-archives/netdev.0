From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: unable to handle kernel NULL pointer dereference in skb_dequeue
Date: Fri, 03 Dec 2010 23:07:01 +0100
Message-ID: <4CF96A05.40908@gmail.com>
References: <0fe401cb92e7$85ba2260$912e6720$@si>	 <1291381791.2897.250.camel@edumazet-laptop>	 <aa43945b38cee751a8231084866b074d@192.168.253.23> <1291387595.2897.350.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrej Ota <andrej@ota.si>, linux-kernel@vger.kernel.org,
	gvs@zemos.net, Rami Rosen <ramirose@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291387595.2897.350.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 15:37 +0100, Andrej Ota a =C3=
=A9crit :
>>>> Patch that works for me is below. Now I only hope I haven't
>>>> (re)introduced a memory leak...
>>
>>> Problem comes from commit 55c95e738da85 (fix return value of
>>> __pppoe_xmit() method)
=2E..
> Rami, could you re-explain the rationale of your patch ?

I guess we could revert it in the meantime: it seems there might be
at least three threads (including bugzilla) with this problem.

Jarek P.
