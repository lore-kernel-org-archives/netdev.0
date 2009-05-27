From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/6]: Get rid of BUS_ID_SIZE in networking
Date: Tue, 26 May 2009 21:39:42 -0700 (PDT)
Message-ID: <20090526.213942.196879926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbZE0Ejm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:39:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The generic device layer got rid of it's bus name string length
limitations by moving to dynamically allocated strings for names.

But there are things all over the tree that indirectly reference the
old BUS_ID_SIZE.

I had this glorious and ambitious patch almost finished that tried to
tackle the MII_BUS_ID_SIZE thing by similarly implementing dynamic
string lengths there but I gave up. :-) It's a lot of work and I do
not have the hardware to test this, and in order to just simply build
all the effected drivers I would have to use 3 or 4 different cross
compiles.  No thanks.

So most of this is in the form of either "get rid of it", "replace
with constant '20'", or "use MII_BUS_ID instead".

I'm pretty sure I got everything in the networking in net-next-2.6,
so if I missed anything let me know.

(Kay, I'll kill the sparc one in my sparc-next-2.6 tree when I
 next get the chance.)
