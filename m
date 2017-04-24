From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] team: fix memory leaks
Date: Mon, 24 Apr 2017 13:04:05 +0200
Message-ID: <20170424110405.GE4126@nanopsycho.orion>
References: <1493029756-13171-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1493029756-13171-1-git-send-email-bianpan2016@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Apr 24, 2017 at 12:29:16PM CEST, bianpan2016@163.com wrote:
>In functions team_nl_send_port_list_get() and
>team_nl_send_options_get(), pointer skb keeps the return value of
>nlmsg_new(). When the call to genlmsg_put() fails, the memory is not
>freed(). This will result in memory leak bugs.
>
>Fixes: 9b00cf2d1024 ("team: implement multipart netlink messages for options transfers")
>Signed-off-by: Pan Bian <bianpan2016@163.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
