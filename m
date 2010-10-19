From: Bandan Das <bandan.das@stratus.com>
Subject: Re: [PATCH] bridge: make br_parse_ip_options  static
Date: Tue, 19 Oct 2010 07:22:34 -0400
Message-ID: <20101019112234.GB12005@stratus.com>
References: <20101018170321.2b0de4ea@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.stratus.com ([134.111.1.18]:52495 "EHLO
	mailhub5.stratus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758363Ab0JSLXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 07:23:22 -0400
Content-Disposition: inline
In-Reply-To: <20101018170321.2b0de4ea@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  0, Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/bridge/br_netfilter.c	2010-10-18 17:01:36.903364885 -0700
> +++ b/net/bridge/br_netfilter.c	2010-10-18 17:01:48.106569141 -0700
> @@ -213,7 +213,7 @@ static inline void nf_bridge_update_prot
>   * expected format
>   */
>  
> -int br_parse_ip_options(struct sk_buff *skb)
> +static int br_parse_ip_options(struct sk_buff *skb)
>  {
>  	struct ip_options *opt;
>  	struct iphdr *iph;
> 

My main motivation behind not making this static was that
there would be possibly other places in the bridge code 
(besides br_netfilter.c) where we enter the IP stack and might 
want to call this. Not sure if it's indeed the case though..

-- 
Bandan
