From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bind() fix error return on wrong address family
Date: Mon, 04 Jul 2011 21:38:08 -0700 (PDT)
Message-ID: <20110704.213808.1604572852149444948.davem@davemloft.net>
References: <1309779029-15403-1-git-send-email-meissner@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, meissner@suse.de, max@suse.de
To: meissner@novell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309779029-15403-1-git-send-email-meissner@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcus Meissner <meissner@novell.com>
Date: Mon,  4 Jul 2011 13:30:29 +0200

> Reinhard Max also pointed out that the error should EAFNOSUPPORT according
> to POSIX.
> 
> The Linux manpages have it as EINVAL, some other OSes (Minix, HPUX, perhaps BSD) use
> EAFNOSUPPORT. Windows uses WSAEFAULT according to MSDN.
> 
> Other protocols error values in their af bind() methods in current mainline git as far
> as a brief look shows:
> 	EAFNOSUPPORT: atm, appletalk, l2tp, llc, phonet, rxrpc
> 	EINVAL: ax25, bluetooth, decnet, econet, ieee802154, iucv, netlink, netrom, packet, rds, rose, unix, x25, 
> 	No check?: can/raw, ipv6/raw, irda, l2tp/l2tp_ip
> 
> Signed-off-by: Marcus Meissner <meissner@suse.de>
> Cc: Reinhard Max <max@suse.de>

Applied to net-2.6, thanks.
