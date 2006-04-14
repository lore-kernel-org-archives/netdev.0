From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the packet
 for packet split
Date: Fri, 14 Apr 2006 17:16:29 -0400
Message-ID: <4440112D.9040509@pobox.com>
References: <20060414183423.3461.32772.stgit@gitlost.site> <20060414183658.3461.4975.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25223 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965167AbWDNVQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 17:16:33 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060414183658.3461.4975.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 2cc9955..7ba1b16 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3770,6 +3770,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
>  			ps_page->ps_page[j] = NULL;
>  			skb->len += length;
>  			skb->data_len += length;
> +			skb->truesize += length;

NAK, apparently this is adding a very serious bug.

	Jeff



