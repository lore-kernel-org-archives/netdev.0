From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: RCU locking avoids touching dev
 refcount
Date: Mon, 2 Nov 2009 22:40:55 +0100
Message-ID: <20091102214055.GA2358@ami.dom.local>
References: <4AEE71EC.7040208@gmail.com>
 <4AEF4B9B.7000205@gmail.com>
 <4AEF504C.7000401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:15343 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbZKBVlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 16:41:19 -0500
Received: by fg-out-1718.google.com with SMTP id 16so170104fgg.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 13:41:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AEF504C.7000401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 10:34:04PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
=2E..
> > So, how is skb->dev protected here, above and below? It seems these
> > rcu read blocks need extending, don't they?
> >=20
>=20
> Well, this might be true, but we run under tasklet (softirq) with pre=
emption disabled.
>=20
> We might move rcu_read_unlock() some lines down to not rely on this.

I think it's needed now at least for readability.

Jarek P.
