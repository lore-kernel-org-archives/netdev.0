From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] net: ipv6: fix error return code
Date: Fri, 31 Aug 2012 16:28:04 -0400 (EDT)
Message-ID: <20120831.162804.1967592304455119019.davem@davemloft.net>
References: <1346258957-7649-1-git-send-email-Julia.Lawall@lip6.fr>
	<1346258957-7649-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346258957-7649-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 29 Aug 2012 18:49:12 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Initialize return variable before exiting on an error path.
> 
> The initial initialization of the return variable is also dropped, because
> that value is never used.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
