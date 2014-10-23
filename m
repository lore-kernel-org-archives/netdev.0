From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net 2/2] sctp: replace seq_printf with seq_puts
Date: Thu, 23 Oct 2014 16:52:32 -0400
Message-ID: <20141023205232.GB26825@hmsreliant.think-freely.org>
References: <1414093721-14921-1-git-send-email-michele@acksyn.org>
 <1414093721-14921-2-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, dborkman@redhat.com
To: Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34436 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641AbaJWUwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 16:52:40 -0400
Content-Disposition: inline
In-Reply-To: <1414093721-14921-2-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 09:48:41PM +0200, Michele Baldessari wrote:
> Fixes checkpatch warning:
> "WARNING: Prefer seq_puts to seq_printf"
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>
> ---
>  net/sctp/proc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index bfb242af06ab..0697eda5aed8 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -490,14 +490,14 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  			 * Note: We don't have a way to tally this at the moment
>  			 * so lets just leave it as zero for the moment
>  			 */
> -			seq_printf(seq, "0 ");
> +			seq_puts(seq, "0 ");
>  
>  			/*
>  			 * remote address start time (START).  This is also not
>  			 * currently implemented, but we can record it with a
>  			 * jiffies marker in a subsequent patch
>  			 */
> -			seq_printf(seq, "0 ");
> +			seq_puts(seq, "0 ");
>  
>  			/*
>  			 * The current state of this destination. I.e.
> -- 
> 2.1.0
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
