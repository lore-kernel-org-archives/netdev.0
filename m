From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arcnet: rimi: Fix device name in debug output
Date: Tue, 17 Apr 2012 22:24:14 -0400 (EDT)
Message-ID: <20120417.222414.1021293399100195501.davem@davemloft.net>
References: <20120415153220.GA11631@vt220.org>
	<alpine.LNX.2.00.1204161335420.16373@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sdyoung@vt220.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jkosina@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204161335420.16373@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Mon, 16 Apr 2012 14:02:48 +0200 (CEST)

> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] arcnet: rimi: Fix device name in debug output
> 
> arcrimi_probe() calls BUGMSG() before register_netdev() happens. BUGMSG()
> itself prints dev->name, but as the format string hasn't been expanded by
> register_netdev() yet, the output contains bogus device name such as
> 
> 	arc%d: Given: node 00h, shmem 0h, irq 0
> 
> As we don't know the device name yet, just drop the prefix completely from
> the debugging messages.
> 
> Reported-by: Steven Young <sdyoung@vt220.org>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Applied, thanks.
