From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] bonding: fix double dev_add_pack
Date: Tue, 06 Mar 2007 06:10:12 -0500
Message-ID: <45ED4C14.2020301@pobox.com>
References: <200703010103.l2113K22030733@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53162 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965845AbXCFLKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:10:19 -0500
In-Reply-To: <200703010103.l2113K22030733@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Bonding can erroneously register the same packet_type to receive
> ARPs (for use by ARP validation): once at device open time, and once via
> sysfs.  Since sysfs can change the validate setting (and thus register
> or unregister) at any time, a flag is needed to synchronize with device
> open in order to avoid double registrations, and the simplest place is
> within the packet_type structure itself.  Double unregister is not an
> issue.
> 
> 	Bug reported by Ulrich Oelmann <ulrich.oelmann@web.de>.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied 1-3


