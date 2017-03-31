From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 net-next 18/18] net: hns: Some checkpatch.pl script &
 warning fixes
Date: Fri, 31 Mar 2017 08:44:57 -0700
Message-ID: <1490975097.27353.10.camel@perches.com>
References: <20170331112032.4692-1-salil.mehta@huawei.com>
         <20170331112032.4692-19-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331112032.4692-19-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-31 at 12:20 +0100, Salil Mehta wrote:
> This patch fixes some checkpatch.pl script caught errors and
> warnings during the compilation time.
[]
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
[]
> @@ -512,7 +512,8 @@ static void hns_nic_reuse_page(struct sk_buff *skb, int i,
>  	int last_offset;
>  	bool twobufs;
>  
> -	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048);
> +	twobufs = ((PAGE_SIZE < 8192) && hnae_buf_size(ring)
> +			== HNS_BUFFER_SIZE_2048);

This would read nicer without splitting a comparison test
onto multiple lines

	twobufs = PAGE_SIZE < 8192 &&
		  hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048;
