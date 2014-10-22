From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: Re-add locking to netlink_lookup() and seq
 walker
Date: Tue, 21 Oct 2014 21:36:04 -0400 (EDT)
Message-ID: <20141021.213604.498626106621926349.davem@davemloft.net>
References: <14101d52c64e0d52176ca0d4b8888f8cf20ab9b0.1413921873.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.ne, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14101d52c64e0d52176ca0d4b8888f8cf20ab9b0.1413921873.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 21 Oct 2014 22:05:38 +0200

> The synchronize_rcu() in netlink_release() introduces unacceptable
> latency. Reintroduce minimal lookup so we can drop the
> synchronize_rcu() until socket destruction has been RCUfied.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
> Reported-and-tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable.

Please use an appropriate "Fixes: " tag in the future, this is
especially important for an issue as serious as this one.

Thanks.
