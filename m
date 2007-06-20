From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] bonding: Fix use after free in unregister path
Date: Wed, 20 Jun 2007 19:12:54 -0400
Message-ID: <4679B476.9060503@garzik.org>
References: <1178862045.3979.33.camel@kane-linux> <20070511092519.1f34ab34@freepuppy> <1179130660.3881.23.camel@kane-linux> <20070514085840.17a343f7@freepuppy> <20070613094521.GA8860@localdomain> <20070613155335.47111c67@localhost> <15712.1181795790@death> <20070619082302.4b9a5c27@localhost.localdomain> <467817CE.80904@garzik.org> <24302.1182276732@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dan Aloni <da-x@monatomic.org>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45583 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753021AbXFTXNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:13:09 -0400
In-Reply-To: <24302.1182276732@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	The following patch (based on a patch from Stephen Hemminger
> <shemminger@linux-foundation.org>) removes use after free conditions in
> the unregister path for the bonding master.  Without this patch, an
> operation of the form "echo -bond0 > /sys/class/net/bonding_masters"
> would trigger a NULL pointer dereference in sysfs.  I was not able to
> induce the failure with the non-sysfs code path, but for consistency I
> updated that code as well.
> 
> 	I also did some testing of the bonding /proc file being open
> while the bond is being deleted, and didn't see any problems there.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied to #upstream-fixes


