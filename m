From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Remove hidden flow control goto from
 BNX2X_ALLOC macros
Date: Tue, 25 Feb 2014 17:37:14 -0500 (EST)
Message-ID: <20140225.173714.863570499882066264.davem@davemloft.net>
References: <1392931551.2594.9.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392931551.2594.9.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 20 Feb 2014 13:25:51 -0800

> BNX2X_ALLOC macros use "goto alloc_mem_err"
> so these labels appear unused in some functions.
> 
> Expand these macros in-place via coccinelle and
> some typing.
> 
> Update the macros to use statement expressions
> and remove the BNX2X_ALLOC macro.
> 
> This adds some > 80 char lines.
 ...
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
