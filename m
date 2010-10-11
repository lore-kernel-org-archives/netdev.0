From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ATM: solos-pci, remove use after free
Date: Mon, 11 Oct 2010 10:19:29 +0200
Message-ID: <1286785169.2737.3.camel@edumazet-laptop>
References: <1286783444-7719-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286783444-7719-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 11 octobre 2010 =C3=A0 09:50 +0200, Jiri Slaby a =C3=A9crit :
> Stanse found we do in console_show:
>   kfree_skb(skb);
>   return skb->len;
> which is not good. Fix that by remembering the len and use it in the
> function instead.
>=20
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
