From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c574_cs: fix operator precedence between << and &
Date: Thu, 17 Jan 2013 15:05:02 -0500 (EST)
Message-ID: <20130117.150502.1981147330754808185.davem@davemloft.net>
References: <1358443109-63402-1-git-send-email-nickolai@csail.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nickolai@csail.mit.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358443109-63402-1-git-send-email-nickolai@csail.mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nickolai Zeldovich <nickolai@csail.mit.edu>
Date: Thu, 17 Jan 2013 12:18:29 -0500

> The code to print the FIFO size in tc574_config computes it as:
> 
>   8 << config & Ram_size
> 
> which evaluates the '<<' first, but the actual intent is to evaluate the
> '&' first.  Add parentheses to enforce desired evaluation order.
> 
> Signed-off-by: Nickolai Zeldovich <nickolai@csail.mit.edu>

Applied.
