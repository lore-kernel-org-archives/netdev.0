From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851: Update link status during link change interrupt
Date: Fri, 11 May 2012 18:23:51 -0400 (EDT)
Message-ID: <20120511.182351.1369330702016518524.davem@davemloft.net>
References: <1336690290-21304-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben-linux@fluff.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336690290-21304-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Thu, 10 May 2012 15:51:30 -0700

> If a link change interrupt comes in we just clear the interrupt
> and continue along without notifying the upper networking layers
> that the link has changed. Use the mii_check_link() function to
> update the link status whenever a link change interrupt occurs.
> 
> Cc: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied, thanks.
