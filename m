From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tsi108: use NULL for pointer-typed argument
Date: Tue, 26 Apr 2016 01:11:30 -0400 (EDT)
Message-ID: <20160426.011130.579576502644948065.davem@davemloft.net>
References: <1461402422-10879-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1461402422-10879-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 23 Apr 2016 11:07:02 +0200

> The first argument of pci_free_consistent has type struct pci_dev *, so use
> NULL instead of 0.
> 
> The semantic patch that performs this transformation is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> @@
> pci_free_consistent(
> - 0
> + NULL
>   , ...)
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
