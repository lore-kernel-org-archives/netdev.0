From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4 (resent) net-2.6.25][UNIX] Make the unix sysctl tables per-namespace
Date: Sat, 1 Dec 2007 23:57:26 +1100
Message-ID: <20071201125726.GC15910@gondor.apana.org.au>
References: <47503919.8060103@openvz.org> <47503C48.8020001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3336 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753402AbXLAM5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:57:38 -0500
Content-Disposition: inline
In-Reply-To: <47503C48.8020001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 07:37:28PM +0300, Pavel Emelyanov wrote:
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

All applied to net-2.6.25.

> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index b0cf075..f97b2a4 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -41,6 +43,7 @@ struct net {
>  
>  	/* unix sockets */
>  	int			sysctl_unix_max_dgram_qlen;
> +	struct ctl_table_header	*unix_ctl;
>  };

But I gotta say this struct/file is going to be enormous.  It's also
one of those files that causes everything to get recompiled.  Maybe
we ought to make a rule that each subsystem only gets to have at most
one entry in it :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
