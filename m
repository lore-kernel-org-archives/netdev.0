From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] can: Fix kernel panic at security_sock_rcv_skb
Date: Thu, 12 Jan 2017 15:10:18 -0800
Message-ID: <1484262618.13165.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484260855-15844-1-git-send-email-william.c.roberts@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, socketcan@hartkopp.net, mkl@pengutronix.de,
        davem@davemloft.net, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sds@tycho.nsa.gov, paul@paul-moore.com,
        Zhang Yanmin <yanmin.zhang@intel.com>, He@vger.kernel.org,
        Bo <bo.he@intel.com>, Liu Shuo A <shuo.a.liu@intel.com>
To: william.c.roberts@intel.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1484260855-15844-1-git-send-email-william.c.roberts@intel.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-12 at 14:40 -0800, william.c.roberts@intel.com wrote:
> From: Zhang Yanmin <yanmin.zhang@intel.com>
> 
> The patch is for fix the below kernel panic:
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff81495e25>] selinux_socket_sock_rcv_skb+0x65/0x2a0

Same patch was sent earlier, and we gave a feedback on it.

Adding synchronize_rcu() calls is a step backward.

https://patchwork.ozlabs.org/patch/714446/




