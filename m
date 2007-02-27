From: Paul Moore <paul.moore@hp.com>
Subject: Re: [NET]: Fix kfree(skb)
Date: Tue, 27 Feb 2007 12:35:22 -0500
Message-ID: <200702271235.22671.paul.moore@hp.com>
References: <45E46518.5070100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:54575 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbXB0Rfc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 12:35:32 -0500
In-Reply-To: <45E46518.5070100@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, February 27 2007 12:06:32 pm Patrick McHardy wrote:
> diff --git a/net/netlabel/netlabel_unlabeled.c
> b/net/netlabel/netlabel_unlabeled.c index 5bc3718..b931ede 100644
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -173,7 +173,7 @@ static int netlbl_unlabel_list(struct sk
> =A0=A0=A0=A0=A0=A0=A0=A0return 0;
> =A0
> =A0list_failure:
> -=A0=A0=A0=A0=A0=A0=A0kfree(ans_skb);
> +=A0=A0=A0=A0=A0=A0=A0kfree_skb(ans_skb);
> =A0=A0=A0=A0=A0=A0=A0=A0return ret_val;
> =A0}

Acked-by: Paul Moore <paul.moore@hp.com>

Thanks for catching this, it looks like I used kfree_skb() elsewhere bu=
t for=20
some reason missed it here.

--=20
paul moore
linux security @ hp
