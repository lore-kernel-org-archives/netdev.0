From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Tue, 7 Jun 2016 17:14:58 +0200
Message-ID: <20160607151458.GA18008@salvia>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
 <1462843618-21914-2-git-send-email-me@tobin.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: tcharding <me@tobin.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56557 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161110AbcFGPPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 11:15:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 4FFB6921768
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:15:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 404F7158F02
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:15:02 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1599E158F20
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 17:15:00 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1462843618-21914-2-git-send-email-me@tobin.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, May 10, 2016 at 11:26:56AM +1000, tcharding wrote:
> From: Tobin C Harding <me@tobin.cc>
> 
> checkpatch produces various white space 'checks'.
> 
> This patch amends them.
> 
> Signed-off-by: Tobin C Harding <me@tobin.cc>
> ---
> This is my second linux kernel patch. Unsure if I was meant to cc multiple mailing lists?
> 
> thanks
> 
>  net/bridge/netfilter/ebt_stp.c | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
> index 6b731e1..26a0859 100644
> --- a/net/bridge/netfilter/ebt_stp.c
> +++ b/net/bridge/netfilter/ebt_stp.c
> @@ -55,65 +55,65 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
>  	if (info->bitmask & EBT_STP_ROOTPRIO) {
>  		v16 = NR16(stpc->root);
>  		if (FWINV(v16 < c->root_priol ||
> -		    v16 > c->root_priou, EBT_STP_ROOTPRIO))
> +			  v16 > c->root_priou, EBT_STP_ROOTPRIO))

I don't think this coding style is right. This is a common approach
(to align the condition when split in several lines) in other 'net' code.
