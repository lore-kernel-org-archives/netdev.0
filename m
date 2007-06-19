From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Why is this patch not in 2.6.22-rc5?
Date: Tue, 19 Jun 2007 13:52:14 -0400
Message-ID: <467817CE.80904@garzik.org>
References: <1178862045.3979.33.camel@kane-linux>	<20070511092519.1f34ab34@freepuppy>	<1179130660.3881.23.camel@kane-linux>	<20070514085840.17a343f7@freepuppy>	<20070613094521.GA8860@localdomain>	<20070613155335.47111c67@localhost>	<15712.1181795790@death> <20070619082302.4b9a5c27@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dan Aloni <da-x@monatomic.org>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33846 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755460AbXFSRwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 13:52:42 -0400
In-Reply-To: <20070619082302.4b9a5c27@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 13 Jun 2007 21:36:30 -0700
> Jay Vosburgh <fubar@us.ibm.com> wrote:
> 
>> 	The following patch (based on a patch from Stephen Hemminger
>> <shemminger@linux-foundation.org>) removes use after free conditions in
>> the unregister path for the bonding master.  Without this patch, an
>> operation of the form "echo -bond0 > /sys/class/net/bonding_masters"
>> would trigger a NULL pointer dereference in sysfs.  I was not able to
>> induce the failure with the non-sysfs code path, but for consistency I
>> updated that code as well.
>>
>> 	I also did some testing of the bonding /proc file being open
>> while the bond is being deleted, and didn't see any problems there.
>>
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 	
> Hey David, this patch fixes one of the bugs listed in 2.6.22-rc5
> list. Jay submitted last week but it hasn't made it upstream.

Get him to forward it to me, like he does for other bonding patches...

	Jeff



