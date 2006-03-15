From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/decnet/dn_route.c: fix inconsequent NULL
 checking
Date: Tue, 14 Mar 2006 17:06:48 -0800 (PST)
Message-ID: <20060314.170648.23393069.davem@davemloft.net>
References: <20060310230233.GB21864@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick@tykepenguin.com, linux-decnet-user@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932187AbWCOBG7@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060310230233.GB21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 11 Mar 2006 00:02:33 +0100

> The Coverity checker noted this inconsequent NULL checking in
> dnrt_drop().
> 
> Since all callers ensure that NULL isn't passed, we can simply remove 
> the check.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
