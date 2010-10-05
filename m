From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Tue, 05 Oct 2010 17:19:07 +0200
Message-ID: <1286291947.2796.387.camel@edumazet-laptop>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
	 <1286290393.7071.38.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43617 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0JEPTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 11:19:14 -0400
Received: by fxm4 with SMTP id 4so465346fxm.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 08:19:13 -0700 (PDT)
In-Reply-To: <1286290393.7071.38.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 16:53 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :

> Its already racy, because "ethtool -S" reads out the stats immediatel=
y,
> and thus races with the timer.
>=20
> See: igb_ethtool.c
>  igb_get_ethtool_stats() invoke igb_update_stats(adapter);
>=20

You would be surprised how many bugs are waiting to be found and
fixed ;)



