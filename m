From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: set the value of flowi6_oif to sk_bound_dev_if
 to make sctp_v6_get_dst to find the correct route entry.
Date: Thu, 06 Jul 2017 11:40:20 +0100 (WEST)
Message-ID: <20170706.114020.1164331043260731183.davem@davemloft.net>
References: <1499324409-12489-1-git-send-email-lizheng043@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, jmorris@namei.org,
        james.z.li@ericsson.com, allen.y.zhao@ericsson.com,
        feng.qiu@ericsson.com
To: lizheng043@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499324409-12489-1-git-send-email-lizheng043@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <lizheng043@gmail.com>
Date: Thu,  6 Jul 2017 15:00:09 +0800

> From: Zheng Li <james.z.li@ericsson.com>
> 
> if there are several same route entries with different outgoing net device,
> application's socket specifies the oif through setsockopt with
> SO_BINDTODEVICE, sctpv6 should choose the route entry whose outgoing net
> device is the oif which was specified by socket, set the value of
> flowi6_oif to sk->sk_bound_dev_if to make sctp_v6_get_dst to find the
> correct route entry.
> 
> Signed-off-by: Zheng Li <james.z.li@ericsson.com>

Applied, thanks.
