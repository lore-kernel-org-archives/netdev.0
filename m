From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] geneve: fix max_mtu setting
Date: Mon, 04 Jul 2016 14:50:54 -0700 (PDT)
Message-ID: <20160704.145054.701386332958657320.davem@davemloft.net>
References: <1467442968-13723-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, pshelar@nicira.com, tom@herbertland.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467442968-13723-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sat,  2 Jul 2016 15:02:48 +0800

> For ipv6+udp+geneve encapsulation data, the max_mtu should subtract
> sizeof(ipv6hdr), instead of sizeof(iphdr).
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied and queued up for -stable, thanks.
