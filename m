From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix warning from Sparse for socfpga
Date: Wed, 27 Aug 2014 16:33:43 -0700 (PDT)
Message-ID: <20140827.163343.715764078341662382.davem@davemloft.net>
References: <1409037076-14775-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lftan.linux@gmail.com, peppe.cavallaro@st.com, vbridger@altera.com
To: lftan@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409037076-14775-1-git-send-email-lftan@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ley Foon Tan <lftan@altera.com>
Date: Tue, 26 Aug 2014 15:11:16 +0800

> @@ -119,7 +119,8 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>  			return -EINVAL;
>  		}
>  
> -		dwmac->splitter_base = (void *)devm_ioremap_resource(dev,
> +		dwmac->splitter_base =
> +			(void __iomem *)devm_ioremap_resource(dev,
>  			&res_splitter);

Please either put this entire call on one line (it'll only be slightly
over 80 columns, which is fine), or indent it properly.

And by properly I meant that the second and subsequent lines of a function
call must be indented precisely to the first column after the openning
parenthesis of the function call on the first line.  You must use the
appropriate number of TAB and SPACE characters necessary to do so.

If it is indented using only TAB characters, it is very likely that you
are doing it wrong.

Thanks.
