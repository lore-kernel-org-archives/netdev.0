From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/13 v2] wimax/i2400m: make return of 0 explicit
Date: Wed, 21 May 2014 17:19:37 -0400 (EDT)
Message-ID: <20140521.171937.898588239489051362.davem@davemloft.net>
References: <1400473875-22228-5-git-send-email-Julia.Lawall@lip6.fr>
	<5379FD39.7020605@cogentembedded.com>
	<alpine.DEB.2.10.1405200844010.2723@hadrien>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, inaky.perez-gonzalez@intel.com,
	kernel-janitors@vger.kernel.org, linux-wimax@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1405200844010.2723@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 20 May 2014 08:44:49 +0800 (SGT)

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Delete unnecessary local variable whose value is always 0 and that hides
> the fact that the result is always 0.
> 
> A simplified version of the semantic patch that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> Alternatively, is an error code wanted under the if?
> 
> v2: remove the use of 0 as an argument in the call to d_fnend

Applied to net-next, thanks.
