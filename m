From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/tokenring: Use status field rather than
 state field
Date: Wed, 12 Aug 2009 21:19:07 -0700 (PDT)
Message-ID: <20090812.211907.124112530.davem@davemloft.net>
References: <Pine.LNX.4.64.0908080846000.25176@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751439AbZHMES6@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0908080846000.25176@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sat, 8 Aug 2009 08:47:33 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> In general in this file, it is the status field, not the state field, that
> contains values like OPEN and CLOSED.  Indeed, in the first error case, it
> is the field status that is initialized.  I have thus assumed that all of
> the error handling code should be the same, and moved it to the end of the
> function to emphasize its commonality.
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
