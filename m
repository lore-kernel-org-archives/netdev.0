From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ipv4: refine the logic for determining daddr
 in ip_queue_xmit.
Date: Mon, 14 Jan 2013 23:48:07 -0500 (EST)
Message-ID: <20130114.234807.263597221162955409.davem@davemloft.net>
References: <1358225255-30973-1-git-send-email-harvey.huawei.yang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: harvey.huawei.yang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358225255-30973-1-git-send-email-harvey.huawei.yang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harvey Yang <harvey.huawei.yang@gmail.com>
Date: Tue, 15 Jan 2013 12:47:35 +0800

> The destination address daddr is faddr if source route option is set, otherwise it is inet_daddr. So use if-else to assign the value.
> 
> Signed-off-by: Harvey Yang <harvey.huawei.yang@gmail.com>

You are changing nothing in how this code behaves.  And stylistically
I know it was coded this way on purpose, because I'm pretty sure I
wrote it.
