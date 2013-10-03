From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/19 v2] net: myri10ge: Change variable type to bool
Date: Thu, 03 Oct 2013 15:41:24 -0400 (EDT)
Message-ID: <20131003.154124.919042100815203643.davem@davemloft.net>
References: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
	<1380716391-20214-3-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hykim@myri.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380716391-20214-3-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Wed,  2 Oct 2013 14:19:50 +0200

> There is the rc variable on both myri10ge_ss_lock_napi and
> myri10ge_ss_lock_poll functions. In both cases rc is only assigned the
> values true and false. Both functions already return bool. Change rc
> type to bool.
> 
> The simplified semantic patch that find this problem is as
> follows (http://coccinelle.lip6.fr/):
> 
> @exists@
> type T;
> identifier b;
> @@
> - T
> + bool
>   b = ...;
>   ... when any
>   b = \(true\|false\)
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied.
