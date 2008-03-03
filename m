From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 net-2.6.26] [SCTP]: seq_printf format warning.
 (fixed)
Date: Mon, 03 Mar 2008 11:56:53 -0800 (PST)
Message-ID: <20080303.115653.237789682.davem@davemloft.net>
References: <20080304.023934.56690002.yoshfuji@linux-ipv6.org>
	<1204566818-23881-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI@sw.ru
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751011AbYCCT5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:57:09 -0500
In-Reply-To: <1204566818-23881-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon,  3 Mar 2008 20:53:38 +0300

> sctp_association->hbinterval is unsigned long. Replace %8d with %8ld.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
 ...
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 82bea30..138ab5f 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -325,7 +325,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  		seq_printf(seq,
>  			   "%8p %8p %-3d %-3d %-2d %-4d "
>  			   "%4d %8d %8d %7d %5lu %-5d %5d "
> -			   "%8d %5d %5d %4d %4d %4d %8d ",
> +			   "%8lu %5d %5d %4d %4d %4d %8d ",
>  			   assoc, sk, sctp_sk(sk)->type, sk->sk_state,
>  			   assoc->state, hash,
>  			   assoc->assoc_id,

Haste makes waste.

You fixed up the patch but didn't update the changelog entry.  I've
fixed it up, but please just take your time when respinning patches to
avoid errors like this.  It is not a race, and you will not be timed.
