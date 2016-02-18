From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: prevent possible NULL pointer dereference
Date: Thu, 18 Feb 2016 15:00:04 -0500 (EST)
Message-ID: <20160218.150004.624016127272800990.davem@davemloft.net>
References: <1455725996-10538-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: a.s.protopopov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455725996-10538-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Protopopov <a.s.protopopov@gmail.com>
Date: Wed, 17 Feb 2016 11:19:56 -0500

> A return value of the bchannel_get_rxbuf() function is compared with the
> positive ENOMEM value instead of the negative -ENOMEM value to detect a
> memory allocation problem. Thus, after a possible memory allocation
> failure the bc->bch.rx_skb will be NULL which will lead to a NULL
> pointer dereference.
> 
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

Applied.
