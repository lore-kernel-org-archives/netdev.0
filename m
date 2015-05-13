From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next 1/1] hv_netvsc: Use the xmit_more skb flag
 to optimize signaling the host
Date: Tue, 12 May 2015 23:11:09 -0400 (EDT)
Message-ID: <20150512.231109.1616986859834741343.davem@davemloft.net>
References: <1431383986-30850-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431383986-30850-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Mon, 11 May 2015 15:39:46 -0700

> Based on the information given to this driver (via the xmit_more skb flag),
> we can defer signaling the host if more packets are on the way. This will help
> make the host more efficient since it can potentially process a larger batch of
> packets. Implement this optimization.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thank you.
