From: David Miller <davem@davemloft.net>
Subject: Re: active-backup/bonding with drivers not supporting
 set_mac_address()
Date: Mon, 10 Jul 2006 11:46:14 -0700 (PDT)
Message-ID: <20060710.114614.32199826.davem@davemloft.net>
References: <Pine.LNX.4.64.0607101618390.26558@zuben>
	<20060710.112322.100334803.davem@davemloft.net>
	<200607101831.k6AIVmp0026998@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@voltaire.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50128
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422760AbWGJSph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 14:45:37 -0400
To: fubar@us.ibm.com
In-Reply-To: <200607101831.k6AIVmp0026998@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 10 Jul 2006 11:31:48 -0700

> David Miller <davem@davemloft.net> wrote:
> [...]
> >Regardless of whether we add support for active-backup/bonding for
> >devices without this method, in the mean time the bonding
> >driver should check for whether that method is NULL and disallow
> >the bond configuration if it is.
> 
> 	That's what it does; if a slave lacks a set_mac_address
> function, the enslavement fails.  Changes to the MAC are done via
> dev_set_mac_address.

Ok, please see my other comments about the ramifications of
devices that end up with the default eth_mac_addr() software
implementation.
