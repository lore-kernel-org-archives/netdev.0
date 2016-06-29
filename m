From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: tundra: Correct argument for
 pci_free_consistent
Date: Wed, 29 Jun 2016 04:09:58 -0400 (EDT)
Message-ID: <20160629.040958.299678054266027059.davem@davemloft.net>
References: <20160627090450.GA19412@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160627090450.GA19412@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Mon, 27 Jun 2016 14:34:50 +0530

> pci_free_consistent's argument 'struct pci_dev' should be NULL not 0.
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @@
> @@
> 
> pci_free_consistent(
> - 0
> + NULL
>   , ...)
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

This patch doesn't apply.
