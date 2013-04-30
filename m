From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/3] tipc: cosmetic: clean up comments
Date: Tue, 30 Apr 2013 15:54:01 +0400
Message-ID: <517FB0D9.1070404@cogentembedded.com>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com> <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com,
	holger.brunck@keymile.com
To: Gerlando Falauto <gerlando.falauto@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:39743 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759863Ab3D3Ly0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 07:54:26 -0400
Received: by mail-la0-f45.google.com with SMTP id el20so338067lab.4
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 04:54:25 -0700 (PDT)
In-Reply-To: <1367307199-10577-1-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 30-04-2013 11:33, Gerlando Falauto wrote:

> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
> ---
> Changes from v2:
> * Split cosmetic from functional changes

>   net/tipc/bcast.c |   13 +++++++------
>   1 file changed, 7 insertions(+), 6 deletions(-)

> diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
> index 2655c9f..8438e01 100644
> --- a/net/tipc/bcast.c
> +++ b/net/tipc/bcast.c
> @@ -584,8 +584,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
>   {
>   	int bp_index;
>
> -	/*
> -	 * Prepare broadcast link message for reliable transmission,
> +	/* Prepare broadcast link message for reliable transmission,
>   	 * if first time trying to send it;
>   	 * preparation is skipped for broadcast link protocol messages
>   	 * since they are sent in an unreliable manner and don't need it
> @@ -613,11 +612,12 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
>   		struct tipc_bearer *s = bcbearer->bpairs[bp_index].secondary;
>
>   		if (!p)
> -			break;	/* no more bearers to try */
> +			break; /* No more bearers to try */
>
> -		tipc_nmap_diff(&bcbearer->remains, &p->nodes, &bcbearer->remains_new);
> +		tipc_nmap_diff(&bcbearer->remains, &p->nodes,
> +			       &bcbearer->remains_new);

    It apeears you nopt only cleaning up comments in this patch but you don't 
mention this change in the changelog...

WBR, Sergei
