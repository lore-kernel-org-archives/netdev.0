From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next 4/4] net: refactor IPv4 and IPv6 defragmentation
 APIs
Date: Mon, 9 Mar 2015 18:15:39 +0900
Message-ID: <20150309091537.GA13498@vergenet.net>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
 <1425888098-21875-5-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:42614 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbbCIJPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:15:50 -0400
Received: by padfa1 with SMTP id fa1so71177526pad.9
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 02:15:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1425888098-21875-5-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Mon, Mar 09, 2015 at 01:01:38AM -0700, Andy Zhou wrote:
> Both ip_defrag() and nf_ct_frag6_gather() derive the name space
> information from the netdev device attached to the skb. However,
> packets processed by  openvswitch may not have a netdev device.
> 
> This patch adds new ip_defrag_net() and  nf_ct_frag6_gather_net()
> API that accepts net as an argument.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>

[snip]

> @@ -645,6 +652,7 @@ void nf_ct_frag6_consume_orig(struct sk_buff *skb)
>  		s = s2;
>  	}
>  }
> +EXPORT_SYMBOL(nf_ct_frag6_consume_orig);
>  
>  static int nf_ct_net_init(struct net *net)
>  {

This hunk seems unrelated to the changelog and the rest of the patch.
