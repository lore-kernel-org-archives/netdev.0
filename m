From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] l2tp: cleanup l2tp_tunnel_delete calls
Date: Fri, 27 Oct 2017 13:49:07 +0900 (KST)
Message-ID: <20171027.134907.120180023049917123.davem@davemloft.net>
References: <20171025135755.25487-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, sd@queasysnail.net,
        g.nault@alphalink.fr, netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025135755.25487-1-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 25 Oct 2017 15:57:55 +0200

> l2tp_tunnel_delete does not return anything since commit 62b982eeb458
> ("l2tp: fix race condition in l2tp_tunnel_delete").  But call sites of
> l2tp_tunnel_delete still do casts to void to avoid unused return value
> warnings.
> 
> Kill these now useless casts.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Appied to net-next, thanks.
