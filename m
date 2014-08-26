From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 2/4] net: moxa: replace build_skb() with
 netdev_alloc_skb_ip_align() / memcpy()
Date: Mon, 25 Aug 2014 17:26:04 -0700 (PDT)
Message-ID: <20140825.172604.1629510702830732700.davem@davemloft.net>
References: <1408544342-32058-1-git-send-email-jonas.jensen@gmail.com>
	<1408976542-15624-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com
To: jonas.jensen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408976542-15624-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Mon, 25 Aug 2014 16:22:22 +0200

> build_skb() is used to make skbs out of existing RX ring memory
> which is bad because the RX ring is allocated only once, on probe.
> Memory corruption occur because said memory is reclaimed, i.e.
> __kfree_skb() (and eventually put_page()).
> 
> Replace build_skb() with netdev_alloc_skb_ip_align() and use memcpy().
> 
> Remove SKB_DATA_ALIGN() from RX buffer size while we're at it.
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69041
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied.
