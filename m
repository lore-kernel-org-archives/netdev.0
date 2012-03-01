From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 15:44:15 -0500 (EST)
Message-ID: <20120301.154415.1692328508436381200.davem@davemloft.net>
References: <20120228.140558.1132853996225815681.davem@davemloft.net>
	<4F4F641E.7000501@collabora.co.uk>
	<1330604802.2465.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: javier.martinez@collabora.co.uk, rodrigo.moya@collabora.co.uk,
	javier@collabora.co.uk, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330604802.2465.43.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Mar 2012 04:26:42 -0800

> Why adding an obscure set of IPC mechanism in network tree, and not
> using (maybe extending) traditional IPC (Messages queues, semaphores,
> Shared memory, pipes, futexes, ...).

I actually don't understand why there is so much resistence to using a
real bonafide on-the-wire protocol, and that way if you ever wanted to
connect dbus instances on multiple machines or log dbus transactions
remotely for debugging, you could just do it.
