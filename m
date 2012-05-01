From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: remove some bloat
Date: Tue, 1 May 2012 09:57:43 +0300
Message-ID: <1335855463.12363.16.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1335598761.2900.49.camel@edumazet-glaptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Neal Cardwell" <ncardwell@google.com>,
	"Tom Herbert" <therbert@google.com>,
	"Maciej =?UTF-8?Q?=C5=BBenczykowski?=" <maze@google.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2107 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab2EAG61 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 02:58:27 -0400
In-Reply-To: <1335598761.2900.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-04-28 at 09:39 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Before doing skb->head_frag work on bnx2x driver, I found too much st=
uff
> was inlined in bnx2x/bnx2x_cmn.h for no good reason and made my work =
not
> very easy.
>=20
> Move some big functions out of this include file to the respective .c
> file.
>=20
> A lot of inline keywords are not needed at all in this huge driver.
>=20
>    text	   data	    bss	    dec	    hex	filename
>  490083	   1270	     56	 491409	  77f91	bnx2x/bnx2x.ko.before
>  484206	   1270	     56	 485532	  7689c	bnx2x/bnx2x.ko
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>

Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Eric - it makes sense.
