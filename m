From: Christoph Hellwig <hch@lst.de>
Subject: skb_migrate() / net/atm/ipcommon.c
Date: Thu, 25 Sep 2003 14:19:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925121941.GA409@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


net/atm/ipcommon.c has a single function in it, skb_migrate which
looks pretty generic and his this comment ontop of it:

 *
 * This function should live in skbuff.c or skbuff.h.
 *

So does this comment make sense, should it go into common code
(and kill the major ugliness in net/atm/Makefile :))
