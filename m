From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Mon, 16 Nov 2015 15:53:27 -0500 (EST)
Message-ID: <20151116.155327.1432148371996261050.davem@davemloft.net>
References: <1447698216-7635-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447698216-7635-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mans Rullgard <mans@mansr.com>
Date: Mon, 16 Nov 2015 18:23:35 +0000

> +static int nb8800_alloc_rx(struct net_device *dev, int i, bool napi)

"i" is passed in as a signed int here, but:

> +static void nb8800_receive(struct net_device *dev, unsigned i, unsigned len)
 ...
> +		err = nb8800_alloc_rx(dev, i, true);

It comes from an 'unsigned' value.

Please pick one type and use it consistently.

Also, always fully spell out "unsigned int" rather than use "unsigned"
as a shorthand.

Thanks.
