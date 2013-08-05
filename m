From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/vmw_vsock/af_vsock.c: drop unneeded semicolon
Date: Mon, 05 Aug 2013 11:08:43 -0700 (PDT)
Message-ID: <20130805.110843.938924468911400543.davem@davemloft.net>
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
	<1375714059-29567-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375714059-29567-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon,  5 Aug 2013 16:47:38 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Drop the semicolon at the end of the list_for_each_entry loop header.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> Not tested, but I can't imagine how the current code could work, since vsk
> should end up pointing to a dummy value.

This bug has been there since the code was first checked in, and indeed
it's going to work on garbage since it's going to pass in the list
head transformed into a vsock structure.

Applied, thanks Julia.
