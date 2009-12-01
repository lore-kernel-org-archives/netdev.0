From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Support 20-byte link layer address in idxmap
Date: Tue, 1 Dec 2009 15:42:07 -0800
Message-ID: <20091201154207.498b9ce5@nehalam>
References: <1255632801-17802-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Ward <david.ward@ll.mit.edu>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42251 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbZLAXmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 18:42:07 -0500
In-Reply-To: <1255632801-17802-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2009 14:53:21 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> Extend the link-layer address field from 8 to 20 bytes to support InfiniBand.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---
>  lib/ll_map.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/ll_map.c b/lib/ll_map.c
> index 7c0bea2..5addf4a 100644
> --- a/lib/ll_map.c
> +++ b/lib/ll_map.c
> @@ -31,7 +31,7 @@ struct idxmap
>  	int		type;
>  	int		alen;
>  	unsigned	flags;
> -	unsigned char	addr[8];
> +	unsigned char	addr[20];
>  	char		name[16];
>  };
>  

makes sense applied

-- 
