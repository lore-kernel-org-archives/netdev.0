From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make it possible to set defaults for
 net.core.[rw]mem_max parameters
Date: Thu, 19 Dec 2013 15:11:09 -0500 (EST)
Message-ID: <20131219.151109.331529110864072765.davem@davemloft.net>
References: <1387272353-3560-1-git-send-email-k.lewandowsk@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyungmin.park@samsung.com,
	lennart@poettering.net, linux-kernel@vger.kernel.org
To: k.lewandowsk@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387272353-3560-1-git-send-email-k.lewandowsk@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karol Lewandowski <k.lewandowsk@samsung.com>
Date: Tue, 17 Dec 2013 10:25:53 +0100

> Default limits are quite low even for today's embedded hardware.
> 
> Signed-off-by: Karol Lewandowski <k.lewandowsk@samsung.com>

You can up the default, but adding a Kconfig option is not necessary.
People can add knobs to /etc/sysctl.conf if they want, that's what
it is there fore.
