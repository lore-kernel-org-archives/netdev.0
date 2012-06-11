From: Fengguang Wu <wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Mon, 11 Jun 2012 09:44:10 +0800
Message-ID: <20120611014410.GA6436@localhost>
References: <20120610015832.GA9175@localhost> <20120610020801.GA9293@localhost>
	<20120609.190929.1165462964087672866.davem@davemloft.net>
	<20120609.221801.2226110181753212240.davem@davemloft.net>
	<20120610101640.GA14476@localhost>
	<4FD53B74.1050409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FD53B74.1050409-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

> seams you did not pull the last codes
> David has delete the tcp_v(4,6)_tw_get_peer
> in commit 2397849baa7c44c242e5d5142d5d16d1e7ed53d0.

Ah OK, I retested net-next head and it compiles fine, except for these
errors I reported in another thread:

ERROR: "stmmac_pltfr_driver" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefined!
ERROR: "stmmac_pci_driver" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefined!

It seems the bug fixing patch

        stmmac: fix driver built w/ w/o both pci and platf modules

was only applied to net/master, but not in net-next/master yet.

Thanks,
Fengguang
