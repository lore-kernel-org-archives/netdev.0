From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: Format IPv6 tunnels endpoints nicely.
Date: Tue, 19 Jun 2007 16:29:18 -0700
Message-ID: <20070619162918.523c4348@localhost.localdomain>
References: <20070609135356.GA21251@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lamparter <lists@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41469 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760139AbXFSXbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:31:48 -0400
In-Reply-To: <20070609135356.GA21251@charon.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 9 Jun 2007 15:53:58 +0200
David Lamparter <lists@diac24.net> wrote:

> Change formatting of IPv6 tunnel endpoints from hex chain to standard IPv6
> representation.
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>
> 
> ---
>  lib/ll_addr.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/ll_addr.c b/lib/ll_addr.c
> index 581487d..f558050 100644
> --- a/lib/ll_addr.c
> +++ b/lib/ll_addr.c
> @@ -38,6 +38,9 @@ const char *ll_addr_n2a(unsigned char *addr, int alen, int type, char *buf, int
>  	    (type == ARPHRD_TUNNEL || type == ARPHRD_SIT || type == ARPHRD_IPGRE)) {
>  		return inet_ntop(AF_INET, addr, buf, blen);
>  	}
> +	if (alen == 16 && type == ARPHRD_TUNNEL6) {
> +		return inet_ntop(AF_INET6, addr, buf, blen);
> +	}
>  	l = 0;
>  	for (i=0; i<alen; i++) {
>  		if (i==0) {

Sure applied.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
