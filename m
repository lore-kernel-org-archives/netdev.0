From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for July 6 (NET_DSA + PHYLIB kconfig)
Date: Sat, 10 Jul 2010 19:09:54 -0700 (PDT)
Message-ID: <20100710.190954.245403400.davem@davemloft.net>
References: <20100706190519.93d8b785.sfr@canb.auug.org.au>
	<20100706103417.8923b697.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100706103417.8923b697.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 6 Jul 2010 10:34:17 -0700

> NET_DSA selects PHYLIB.  PHYLIB depends on NET_ETHERNET, which is not enabled
> in this randconfig.  net/dsa code does need PHYLIB code, so PHYLIB symbol should
> either drop "depends on NET_ETHERNET" or it should be changed to
> 	depends on NET_ETHERNET || NET_DSA
> 
> Preference?

The situations seems to suggest NET_DSA depends upon NET_ETHERNET, so
adding NET_ETHERNET to NET_DSA's dependencies probably works better.
