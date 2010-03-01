From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Sun, 28 Feb 2010 23:02:42 -0800 (PST)
Message-ID: <20100228.230242.172227997.davem@davemloft.net>
References: <20100301164721.f8ce9fac.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, marcel@holtmann.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100301164721.f8ce9fac.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 1 Mar 2010 16:47:21 +1100

> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> produced this warning:
> 
> net/bluetooth/hci_sysfs.c: In function 'inquiry_cache_read':
> net/bluetooth/hci_sysfs.c:441: warning: the frame size of 4208 bytes is larger than 2048 bytes
> 
> Introduced by commit ca325f698996c1a0770a67f41e7dc97a007d8bc2
> ("Bluetooth: Convert inquiry cache to use debugfs instead of sysfs")
> which introduces a function with a 4096 char array on the stack.

Thanks Stephen, I'll look into this.
