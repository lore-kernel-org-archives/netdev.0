From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH 1/2] openvswitch: Typo fix.
Date: Wed, 19 Apr 2017 18:56:11 -0700
Message-ID: <A76BA0F5-BF50-479D-AC4E-FCE0DBDB835B@ovn.org>
References: <1492652976-99201-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34732 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938909AbdDTB4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 21:56:15 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so10274628ioi.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 18:56:14 -0700 (PDT)
In-Reply-To: <1492652976-99201-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the chatter, forgot to include “net-next” in the title, sending again.

  Jarno

> On Apr 19, 2017, at 6:49 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> 
> Fix typo in a comment.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
> net/openvswitch/conntrack.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 7b2c2fc..58de4c2 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -373,7 +373,7 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
> 	}
> 
> 	/* Labels are included in the IPCTNL_MSG_CT_NEW event only if the
> -	 * IPCT_LABEL bit it set in the event cache.
> +	 * IPCT_LABEL bit is set in the event cache.
> 	 */
> 	nf_conntrack_event_cache(IPCT_LABEL, ct);
> 
> -- 
> 2.1.4
> 
