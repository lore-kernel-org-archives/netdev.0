From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: Typo fix.
Date: Thu, 20 Apr 2017 08:25:34 -0700
Message-ID: <1492701934.17866.2.camel@gmail.com>
References: <1492653311-99269-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34426 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970449AbdDTPZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:25:37 -0400
Received: by mail-oi0-f68.google.com with SMTP id y11so8532747oie.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:25:37 -0700 (PDT)
In-Reply-To: <1492653311-99269-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 18:55 -0700, Jarno Rajahalme wrote:
> Fix typo in a comment.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/openvswitch/conntrack.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 7b2c2fc..58de4c2 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -373,7 +373,7 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
>  	}
>  
>  	/* Labels are included in the IPCTNL_MSG_CT_NEW event only if the
> -	 * IPCT_LABEL bit it set in the event cache.
> +	 * IPCT_LABEL bit is set in the event cache.
>  	 */
>  	nf_conntrack_event_cache(IPCT_LABEL, ct);
>  

Acked-by: Greg Rose <gvrose8192@gmail.com>
