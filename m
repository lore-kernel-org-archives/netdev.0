From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 30 Aug 2004 17:20:29 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040830172029.164fcf9c.davem@redhat.com>
References: <412DF807.2040703@eurodev.net>
	<20040826141407.38b56729.davem@redhat.com>
	<412EB40A.6010100@eurodev.net>
	<20040826214710.5e322f1a.davem@redhat.com>
	<412F1269.8090303@eurodev.net>
	<20040827172736.543dbd54.davem@redhat.com>
	<413276D9.9080303@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <413276D9.9080303@eurodev.net>
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 02:37:45 +0200
Pablo Neira <pablo@eurodev.net> wrote:

> Attached the 2.4.x version. It just spawns one kernel thread called 
> netlink, is it ok?

It's fine, I'm going to make 2 minor fixes:

1) Mark netlink_thread() function static.
2) Name the thread "knetlinkd" to be consistent with
   other kernel thread names.

Thanks Pablo.

