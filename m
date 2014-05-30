From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ehea: Introduce the use of the managed version of
 kzalloc
Date: Fri, 30 May 2014 15:40:57 -0700 (PDT)
Message-ID: <20140530.154057.1365325960228216056.davem@davemloft.net>
References: <20140528142309.GA4371@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140528142309.GA4371@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Wed, 28 May 2014 19:53:09 +0530

> This patch moves data allocated using kzalloc to managed data allocated
> using devm_kzalloc and cleans now unnecessary kfrees in probe and remove
> functions. Also, linux/device.h is added to make sure the devm_*()
> routine declarations are unambiguously available.
> 
> The following Coccinelle semantic patch was used for making the change:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Compile-Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> ---
> v3: add space in linux/device.h include

Applied to net-next, thanks.
