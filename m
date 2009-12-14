From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] drivers/net/sfc: Correct code taking the size of a
 pointer
Date: Sun, 13 Dec 2009 19:57:29 -0800 (PST)
Message-ID: <20091213.195729.28793749.davem@davemloft.net>
References: <Pine.LNX.4.64.0912131241130.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, shodgson@solarflare.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756585AbZLND5c@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0912131241130.24267@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sun, 13 Dec 2009 12:41:29 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> The function efx_iterate_state contains the code
> memcpy(&payload->msg, payload_msg, sizeof(payload_msg));
> This is the only use of payload_msg.  The type of payload_msg is
> changed from a pointer to an array, so that the result of sizeof really is
> the length of the string.
> 
> A simplified version of the semantic patch that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
