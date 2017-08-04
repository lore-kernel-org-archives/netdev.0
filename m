From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] lwtunnel: replace EXPORT_SYMBOL with
 EXPORT_SYMBOL_GPL
Date: Sat, 5 Aug 2017 00:25:28 +0200
Message-ID: <20170804222528.GD11696@lunn.ch>
References: <1501885417-18966-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52625 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751525AbdHDWZb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 18:25:31 -0400
Content-Disposition: inline
In-Reply-To: <1501885417-18966-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 04, 2017 at 03:23:37PM -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/core/lwtunnel.c | 26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
> index d9cb353..8693ff8 100644
> --- a/net/core/lwtunnel.c
> +++ b/net/core/lwtunnel.c
> @@ -65,7 +65,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
>  
>  	return lws;
>  }
> -EXPORT_SYMBOL(lwtunnel_state_alloc);
> +EXPORT_SYMBOL_GPL_GPL(lwtunnel_state_alloc);

Hi Roopa

GPL_GPL?

	Andrew
