From: David Miller <davem@redhat.com>
Subject: Re: [net PATCH] atl1e: fix dma mapping warnings
Date: Fri, 12 Jul 2013 16:26:52 -0700 (PDT)
Message-ID: <20130712.162652.1236723636413575644.davem@redhat.com>
References: <1373641128-13634-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab3GLX1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 19:27:13 -0400
In-Reply-To: <1373641128-13634-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 12 Jul 2013 10:58:48 -0400

> Recently had this backtrace reported:
 ...
> The usual straighforward failure to check for dma_mapping_error after a map
> operation is completed.
> 
> This patch should fix it, the reporter wandered off after filing this bz:
> https://bugzilla.redhat.com/show_bug.cgi?id=954170
> 
> and I don't have hardware to test, but the fix is pretty straightforward, so I
> figured I'd post it for review.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied with one style fix:

> -static void atl1e_tx_map(struct atl1e_adapter *adapter,
> +static int atl1e_tx_map(struct atl1e_adapter *adapter,
>  		      struct sk_buff *skb, struct atl1e_tpd_desc *tpd)

I properly reindented the second line of the argument list.

Thanks.
