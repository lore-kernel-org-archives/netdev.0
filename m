From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethoc: fix null dereference in ethoc_probe
Date: Sun, 23 May 2010 23:11:24 -0700 (PDT)
Message-ID: <20100523.231124.236272338.davem@davemloft.net>
References: <20100522155455.GE22515@bicker>
	<1274669042-1901-1-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thierry.reding@avionic-design.de, nios2-dev@sopc.et.ntust.edu.tw,
	error27@gmail.com
To: thomas@wytron.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274669042-1901-1-git-send-email-thomas@wytron.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Chou <thomas@wytron.com.tw>
Date: Mon, 24 May 2010 10:44:02 +0800

> Dan reported the patch 0baa080c75c: "ethoc: use system memory
> as buffer" introduced a potential null dereference.
> 
>   1060  free:
>   1061          if (priv->dma_alloc)
>                     ^^^^^^^^^^^^^^^
> 	priv can be null here.
> 
> He also suggested that the error handling is not complete.
> 
> This patch fixes the null priv issue and improves resources
> releasing in ethoc_probe() and ethoc_remove().
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
