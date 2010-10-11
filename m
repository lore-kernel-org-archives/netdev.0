From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] NET: pch, fix use after free
Date: Mon, 11 Oct 2010 11:38:38 +0200
Message-ID: <1286789918.2737.8.camel@edumazet-laptop>
References: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 11 octobre 2010 =C3=A0 11:26 +0200, Jiri Slaby a =C3=A9crit :
> Stanse found that pch_gbe_xmit_frame uses skb after it is freed. Fix
> that.
>=20
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> ---
>  drivers/net/pch_gbe/pch_gbe_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

Applicable to net-next-2.6 only, this driver is not yet in Linus tree

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
