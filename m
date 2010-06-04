From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: check for refcount if pop a stacked dst_entry
Date: Fri, 04 Jun 2010 14:06:47 +0200
Message-ID: <1275653207.2482.120.camel@edumazet-laptop>
References: <20100604104012.GA13408@secunet.com>
	 <20100604104115.GB13408@secunet.com>
	 <1275648679.2482.43.camel@edumazet-laptop>
	 <20100604115737.GA5570@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47105 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab0FDMGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 08:06:53 -0400
Received: by wyi11 with SMTP id 11so783501wyi.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 05:06:51 -0700 (PDT)
In-Reply-To: <20100604115737.GA5570@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 13:57 +0200, Steffen Klassert a =C3=A9c=
rit :
> xfrm triggers a warning if dst_pop() drops a refcount
> on a noref dst. This patch changes dst_pop() to
> skb_dst_pop(). skb_dst_pop() drops the refcnt only
> on a refcounted dst. Also we don't clone the child
> dst_entry, so it is not refcounted and we can use
> skb_dst_set_noref() in xfrm_output_one().
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---

Thanks a lot Steffen !

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>



