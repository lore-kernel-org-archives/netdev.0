From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix 'ip rule' iif/oif device rename
Date: Fri, 07 Feb 2014 17:41:13 -0800
Message-ID: <1391823673.10160.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391819028-10722-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Chris Davis <chrismd@google.com>,
	Carlo Contavalli <ccontavalli@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42811 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaBHBlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 20:41:15 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so3927517pab.10
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 17:41:15 -0800 (PST)
In-Reply-To: <1391819028-10722-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-07 at 16:23 -0800, Maciej =C5=BBenczykowski wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> ip rules with iif/oif references do not update:
> (detach/attach) across interface renames.
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> CC: Willem de Bruijn <willemb@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Chris Davis <chrismd@google.com>
> CC: Carlo Contavalli <ccontavalli@google.com>
>=20
> Google-Bug-Id: 12936021
> ---
>  net/core/fib_rules.c | 7 +++++++
>  1 file changed, 7 insertions(+)

Acked-by: Eric Dumazet <edumazet@google.com>
