From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: net tree build warnings
Date: Thu, 03 Sep 2009 21:35:48 -0700 (PDT)
Message-ID: <20090903.213548.46609322.davem@davemloft.net>
References: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090904143439.c44f61ee.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 4 Sep 2009 14:34:39 +1000

> Today's linux-next build (x86_64 allmodconfig gcc-4.4.0) produced thes
> warnings:
> 
> drivers/net/wan/dlci.c: In function 'dlci_transmit':
> drivers/net/wan/dlci.c:205: warning: enumeration value 'NETDEV_TX_LOCKED' not handled in switch
> drivers/net/wan/dlci.c:215: warning: case value '2' not in enumerated type 'netdev_tx_t'
> 
> Introduced by commit d71a674922e7519edb477ecb585e7d29d69c7aa7 ("wan:
> convert drivers to netdev_tx_t").

I know about it, this code sucks and it's not easy to quelch that
one trivially.
