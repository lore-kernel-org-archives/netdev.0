From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/isdn/hisax: Drop unused list
Date: Fri, 13 May 2011 16:10:21 -0400 (EDT)
Message-ID: <20110513.161021.1204095204011657113.davem@davemloft.net>
References: <1305296139-16773-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305296139-16773-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Fri, 13 May 2011 16:15:39 +0200

> The file st5481_init.c locally defines and initializes the adapter_list
> variable, but does not use it for anything.  Removing the list makes it
> possible to remove the list field from the st5481_adapter data structure.
> In the function probe_st5481, it also makes it possible to free the locally
> allocated adapter value on an error exit.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks a lot Julia.
