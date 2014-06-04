From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix the section mismatch warnings.
Date: Wed, 04 Jun 2014 14:55:36 -0700 (PDT)
Message-ID: <20140604.145536.2297917264161823878.davem@davemloft.net>
References: <1401871756-29231-1-git-send-email-Li.Xiubo@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, jingchang.lu@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Li.Xiubo@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401871756-29231-1-git-send-email-Li.Xiubo@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiubo Li <Li.Xiubo@freescale.com>
Date: Wed, 4 Jun 2014 16:49:16 +0800

> Building with CONFIG_DEBUG_SECTION_MISMATCH enabled, the following
> WARNING is occured:
> 
>   LD      drivers/net/built-in.o
> WARNING: drivers/net/built-in.o(.text+0xcd4c): Section mismatch in
> reference from the function gfar_probe() to the function
> .init.text:gfar_init_addr_hash_table()
> The function gfar_probe() references
> the function __init gfar_init_addr_hash_table().
> This is often because gfar_probe lacks a __init
> annotation or the annotation of gfar_init_addr_hash_table is wrong.
> 
> Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>

Applied, thanks.
