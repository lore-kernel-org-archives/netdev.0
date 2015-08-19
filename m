From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] lwt: Add cfg argumnt to build_state
Date: Wed, 19 Aug 2015 12:52:11 +0200
Message-ID: <20150819125211.7d2afcaa@griffin>
References: <1439954471-599831-1-git-send-email-tom@herbertland.com>
	<1439954471-599831-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roopa@cumulusnetworks.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbbHSKwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:52:16 -0400
In-Reply-To: <1439954471-599831-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Aug 2015 20:21:10 -0700, Tom Herbert wrote:
> diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
> index e25b60e..9bf7e6a 100644
> --- a/include/net/lwtunnel.h
> +++ b/include/net/lwtunnel.h
> @@ -26,7 +26,8 @@ struct lwtunnel_state {
>  
>  struct lwtunnel_encap_ops {
>  	int (*build_state)(struct net_device *dev, struct nlattr *encap,
> -			   struct lwtunnel_state **ts);
> +			   struct lwtunnel_state **ts,
> +			   unsigned int family, const void *cfg);

Could you please keep the output parameter as the last one?

(It might be better if build_state returned the newly allocated struct
instead and used pointer encoded errors but that's for a different
patch.)

 Jiri

-- 
Jiri Benc
