From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] bonding: fix device name allocation error
Date: Tue, 23 Jan 2007 00:49:18 -0500
Message-ID: <45B5A1DE.4030906@pobox.com>
References: <200701200215.l0K2FV22021761@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>, mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45384 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933010AbXAWFtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:49:24 -0500
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200701200215.l0K2FV22021761@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	The code to select names for the bonding interfaces was, for the
> non-sysfs creation case, always using a hard-coded set of bond0, bond1,
> etc, up to max_bonds.  This caused conflicts for the second or
> subsequent loads of the module.
> 
> 	Changed the code to obtain device names from dev_alloc_name().
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied 1-4 to #upstream


