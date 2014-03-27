From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Thu, 27 Mar 2014 15:28:39 -0400 (EDT)
Message-ID: <20140327.152839.2062547253132146958.davem@davemloft.net>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
	<1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 26 Mar 2014 22:33:40 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Use del_timer_sync to ensure that the timer is stopped on all CPUs before
> the driver exists.
> 
> This change was suggested by Thomas Gleixner.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
