From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: cleanup the unnecessary return value check
Date: Tue, 23 Oct 2012 13:04:15 -0400 (EDT)
Message-ID: <20121023.130415.2072105034807211296.davem@davemloft.net>
References: <1350980483-4992-1-git-send-email-zhanghonghui@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com, edumazet@google.com
To: zhanghonghui@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350980483-4992-1-git-send-email-zhanghonghui@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <zhanghonghui@huawei.com>
Date: Tue, 23 Oct 2012 16:21:23 +0800

> From: Hans Zhang <zhanghonghui@huawei.com>
> 
> It's no needed to check the return value of tab since the NULL situation
> has been handled already, and the rtnl_msg_handlers[PF_UNSPEC] has been
> initialized as non-NULL during the rtnetlink_init().
> 
> Signed-off-by: Hans Zhang <zhanghonghui@huawei.com>

Applied.
