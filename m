From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [RFC][PATCH 0/3] net: generic netdev_ioaddr
Date: Fri, 29 Oct 2004 13:04:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099044244.9566.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch introduces a generic netdev_ioaddr and converts natsemi and
8139too drivers to use it.

With the recent __iomem annotations, the network drivers need to either
invent this wrapper (like natsemi has done) or duplicate the IO base
address in their private data (similar to 8139too).  Therefore, lets
make netdev_ioaddr generic before it is all over the place.

			Pekka
