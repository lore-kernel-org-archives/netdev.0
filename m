From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ksz884x: delete useless variable
Date: Wed, 15 Jan 2014 13:43:52 -0800 (PST)
Message-ID: <20140115.134352.667699585785584026.davem@davemloft.net>
References: <1389629847-5330-1-git-send-email-Julia.Lawall@lip6.fr>
	<1389629847-5330-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389629847-5330-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Mon, 13 Jan 2014 17:17:24 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Delete a variable that is at most only assigned to a constant, but never
> used otherwise.  In this code, it is the variable result that is used for
> the return code, not rc.
> 
> A simplified version of the semantic patch that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thank you.
