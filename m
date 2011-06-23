From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the wireless tree
Date: Wed, 22 Jun 2011 20:46:33 -0700 (PDT)
Message-ID: <20110622.204633.1270632754342154052.davem@davemloft.net>
References: <20110623130317.b3a6085e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, anderson.briglia@openbossa.org,
	anderson.lizardo@openbossa.org, bruna.moreira@openbossa.org,
	vinicius.gomes@openbossa.org, padovan@profusion.mobi,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110623130317.b3a6085e.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 23 Jun 2011 13:03:17 +1000

> Caused by commit d22ef0bc83c5 ("Bluetooth: Add LE SMP Cryptoolbox
> functions").  Missing include file, presumably.  This batch has been in
> the bluetooth tree since June 14, so it may have been exposed by the
> removal of linux/mm.h from netdevice.h ...

This is almost certainly the reason.
