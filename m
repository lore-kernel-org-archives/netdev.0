From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] net: add and use rx_nohandler stat counter
Date: Fri, 29 Jan 2016 19:37:51 -0800 (PST)
Message-ID: <20160129.193751.27856238718097733.davem@davemloft.net>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
	<1453996188-29965-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453996188-29965-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Thu, 28 Jan 2016 10:49:44 -0500

> The network core tries to keep track of dropped packets, but some packets
> you wouldn't really call dropped, so much as intentionally ignored, under
> certain circumstances. One such case is that of bonding and team device
> slaves that are currently inactive. Their respective rx_handler functions
> return RX_HANDLER_EXACT (the only places in the kernel that return that),
> which ends up tracking into the network core's __netif_receive_skb_core()
> function's drop path, with no pt_prev set. On a noisy network, this can
> result in a very rapidly incrementing rx_dropped counter, not only on the
> inactive slave(s), but also on the master device, such as the following:
 ...

Both my inbox and patchwork only show patch 2, 3, and 4.  Where is #1?

Thanks.
