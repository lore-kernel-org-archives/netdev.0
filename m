From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix checkpatch errors
Date: Tue, 3 Jun 2014 21:48:43 +0100
Message-ID: <20140603204843.GA13364@macbook.localnet>
References: <1401806702-3251-1-git-send-email-luca.ellero@brickedbrain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Luca Ellero <luca.ellero@brickedbrain.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41803 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbaFCUst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 16:48:49 -0400
Content-Disposition: inline
In-Reply-To: <1401806702-3251-1-git-send-email-luca.ellero@brickedbrain.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2014 at 04:45:02PM +0200, Luca Ellero wrote:
> Add parenthesis around complex macros
> 
> Signed-off-by: Luca Ellero <luca.ellero@brickedbrain.com>
> ---
>  net/netfilter/nf_conntrack_pptp.c       |    6 +++---
>  net/netfilter/nf_conntrack_proto_sctp.c |    8 ++++----
>  net/netfilter/nf_conntrack_proto_tcp.c  |    8 ++++----
>  3 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
> index 825c3e3..a505263 100644
> --- a/net/netfilter/nf_conntrack_pptp.c
> +++ b/net/netfilter/nf_conntrack_pptp.c
> @@ -92,9 +92,9 @@ const char *const pptp_msg_name[] = {
>  EXPORT_SYMBOL(pptp_msg_name);
>  #endif
>  
> -#define SECS *HZ
> -#define MINS * 60 SECS
> -#define HOURS * 60 MINS
> +#define SECS  (*HZ)
> +#define MINS  (*60 SECS)
> +#define HOURS (*60 MINS)

Don't send patches that you obviously didn't even compile test.
