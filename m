From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 0/2] fixes for net/sctp/auth.c
Date: Thu, 7 Feb 2013 09:52:30 -0500
Message-ID: <20130207145230.GC2379@shamino.rdu.redhat.com>
References: <cover.1360231701.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41143 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758166Ab3BGOwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 09:52:41 -0500
Content-Disposition: inline
In-Reply-To: <cover.1360231701.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 11:55:35AM +0100, Daniel Borkmann wrote:
> This set fixes two issues in the net/sctp/auth.c implementation.
> 
> Daniel Borkmann (2):
>   net: sctp: sctp_auth_make_key_vector: fix undefined ref-count behaviour
>   net: sctp: sctp_auth_key_put: use kzfree instead of kfree
> 
>  net/sctp/auth.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
