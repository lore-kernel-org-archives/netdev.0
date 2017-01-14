From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Remove redundant memset before memcpy
Date: Sat, 14 Jan 2017 12:00:27 -0500 (EST)
Message-ID: <20170114.120027.401686898931069481.davem@davemloft.net>
References: <1484356660-19082-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, tklauser@distanz.ch,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mayhs11saini@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484356660-19082-1-git-send-email-mayhs11saini@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shyam Saini <mayhs11saini@gmail.com>
Date: Sat, 14 Jan 2017 06:47:40 +0530

> The region set by the call to memset, immediately overwritten by
> the subsequent call to memcpy and thus makes the  memset redundant.
> 
> Also remove the memset((&info, 0, sizeof(info)) on line 398 because
> info is memcpy()'ed to before being used in the loop and it isn't
> used outside of the loop.
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>

Applied to net-next, thanks.
