From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ATHEROS-ALX: Use dma_set_mask_and_coherent and fix
 a bug
Date: Mon, 17 Mar 2014 17:20:19 -0400 (EDT)
Message-ID: <20140317.172019.167960066441598788.davem@davemloft.net>
References: <1394926252-2269-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com,
	johannes@sipsolutions.net, jg1.han@samsung.com,
	wangyijing@huawei.com, linux@hahnjo.de, sd@queasysnail.net,
	hahnjo@hahnjo.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394926252-2269-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Sun, 16 Mar 2014 00:30:52 +0100

>  1. For the 64 bits dma mask use dma_set_mask_and_coherent instead of
>  dma_set_mask and dma_set_coherent_mask.
> 
>  2. For the 32 bits dma mask dma_set_coherent_mask is only called if
>  dma_set_mask fails, which is unusual. Assuming this as a bug, fixes
>  it by replacing calls to dma_set_mask and dma_set_coherent_mask by a
>  call to dma_set_mask_and_coherent.
>  
>  Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied, thanks.
