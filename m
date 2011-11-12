From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ah: Don't return NET_XMIT_DROP on input.
Date: Sat, 12 Nov 2011 18:14:22 -0500 (EST)
Message-ID: <20111112.181422.1840921776479927270.davem@davemloft.net>
References: <1320951687-21491-1-git-send-email-nbowler@elliptictech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nbowler@elliptictech.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320951687-21491-1-git-send-email-nbowler@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Bowler <nbowler@elliptictech.com>
Date: Thu, 10 Nov 2011 14:01:27 -0500

> When the ahash driver returns -EBUSY, AH4/6 input functions return
> NET_XMIT_DROP, presumably copied from the output code path.  But
> returning transmit codes on input doesn't make a lot of sense.
> Since NET_XMIT_DROP is a positive int, this gets interpreted as
> the next header type (i.e., success).  As that can only end badly,
> remove the check.
> 
> Signed-off-by: Nick Bowler <nbowler@elliptictech.com>

Applied and queued up for -stable, thanks Nick.
