From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: l2tp: fix a potential issue in l2tp_ip_recv
Date: Mon, 04 Apr 2016 16:01:13 -0400 (EDT)
Message-ID: <20160404.160113.471561314344395898.davem@davemloft.net>
References: <1459692564-3998-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459692564-3998-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sun,  3 Apr 2016 22:09:23 +0800

> pskb_may_pull() can change skb->data, so we have to load ptr/optr at the
> right place.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied and queued up for -stable.
