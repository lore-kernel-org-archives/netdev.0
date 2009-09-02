From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] drop_monitor: fix trace_napi_poll_hit()
Date: Tue, 01 Sep 2009 18:20:13 -0700 (PDT)
Message-ID: <20090901.182013.173315496.davem@davemloft.net>
References: <4A9B6963.5090207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiaoguangrong@cn.fujitsu.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755525AbZIBBT7@vger.kernel.org>
In-Reply-To: <4A9B6963.5090207@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Date: Mon, 31 Aug 2009 14:10:43 +0800

> The net_dev of backlog napi is NULL, like below:
> 
> __get_cpu_var(softnet_data).backlog.dev == NULL
> 
> So, we should check it in napi tracepoint's probe function
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

Applied to net-next-2.6, thanks.
