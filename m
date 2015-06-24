From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: troubleshoot unexpected bits in des0 & des1
Date: Wed, 24 Jun 2015 01:44:40 -0700 (PDT)
Message-ID: <20150624.014440.1731894598101096619.davem@davemloft.net>
References: <20150624.001840.1867851321247997506.davem@davemloft.net>
	<1435133246-15776-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	arc-linux-dev@synopsys.com, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: Alexey.Brodkin@synopsys.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1435133246-15776-1-git-send-email-abrodkin@synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed, 24 Jun 2015 11:07:26 +0300

>  
> -		priv->dma_tx = dma_alloc_coherent(priv->device, txsize *
> +		priv->dma_tx = dma_zalloc_coherent(priv->device, txsize *
>  						  sizeof(struct dma_desc),
>  						  &priv->dma_tx_phy,
>  						  GFP_KERNEL);

When you change the column at which the openning parenthesis of the
function call occurs, you must indent the subsequent lines of the
function call such that the all are adjusted to properly start
at the very next column after that openning parenthesis.'

Please fix this up for all of the dma_zalloc_coherent()
transformations.

Thanks.
