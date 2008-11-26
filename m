From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/53] netns xfrm: add struct xfrm_state::xs_net
Date: Tue, 25 Nov 2008 17:15:36 -0800 (PST)
Message-ID: <20081125.171536.03980167.davem@davemloft.net>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-2-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-3-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752258AbYKZBPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:15:37 -0500
In-Reply-To: <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:26:35 +0300

> To avoid unnecessary complications with passing netns around.
> 
> * set once, very early after allocating
> * once set, never changes
> 
> For a while create every xfrm_state in init_net.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

> @@ -223,6 +226,11 @@ struct xfrm_state
>  	void			*data;
>  };
>  
> +static inline struct net *xs_net(struct xfrm_state *x)
> +{
> +	return read_pnet(&x->xs_net);
> +}
> +
>  /* xflags - make enum if more show up */

Look mom, no ifdefs!  Amazing!
