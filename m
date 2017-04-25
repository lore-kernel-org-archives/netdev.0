From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] team: fix memory leaks
Date: Tue, 25 Apr 2017 11:35:58 -0400 (EDT)
Message-ID: <20170425.113558.689750765066812978.davem@davemloft.net>
References: <1493029756-13171-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bianpan2016@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493029756-13171-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>
Date: Mon, 24 Apr 2017 18:29:16 +0800

> In functions team_nl_send_port_list_get() and
> team_nl_send_options_get(), pointer skb keeps the return value of
> nlmsg_new(). When the call to genlmsg_put() fails, the memory is not
> freed(). This will result in memory leak bugs.
> 
> Fixes: 9b00cf2d1024 ("team: implement multipart netlink messages for options transfers")
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied, thanks.
