From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: asix: Fix crash on skb alloc failure
Date: Mon, 05 Oct 2015 03:31:55 -0700 (PDT)
Message-ID: <20151005.033155.2121849340240343993.davem@davemloft.net>
References: <1443644404-6452-1-git-send-email-linux@davidrobins.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@davidrobins.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443644404-6452-1-git-send-email-linux@davidrobins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "David B. Robins" <linux@davidrobins.net>
Date: Wed, 30 Sep 2015 16:20:04 -0400

> If asix_rx_fixup_internal() fails to allocate rx->ax_skb, it will return
> but not clear rx->size. rx points to driver private data. A later call
> assumes that nonzero size means ax_skb was allocated and passes a null
> ax_skb to skb_put. Changed allocation failure return to clear size first.
> 
> Found testing board with AX88772B devices.
> 
> Signed-off-by: David B. Robins <linux@davidrobins.net>

Applied, thanks.
