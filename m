From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/4] net: moxa: clear DESC1 on ndo_start_xmit()
Date: Mon, 25 Aug 2014 17:25:58 -0700 (PDT)
Message-ID: <20140825.172558.1917292824044947963.davem@davemloft.net>
References: <1408544322-32023-1-git-send-email-jonas.jensen@gmail.com>
	<1408976531-15589-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com
To: jonas.jensen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408976531-15589-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Mon, 25 Aug 2014 16:22:11 +0200

> TX buffer length is not cleared on ndo_start_xmit().
> Failing to do so can bug/hang the controller and
> cause TX interrupts to stop altogether.
> 
> Remove the readl() and compute a new value for DESC1.
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69031
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied.
