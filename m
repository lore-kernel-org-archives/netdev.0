From: David Miller <davem@davemloft.net>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in
 29-rc5
Date: Tue, 17 Feb 2009 14:54:24 -0800 (PST)
Message-ID: <20090217.145424.49927834.davem@davemloft.net>
References: <200902172117.22671.arvidjaar@mail.ru>
	<499B19AF.1000003@hp.com>
	<16929.1234904788@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, arvidjaar@mail.ru, jamagallon@ono.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	bonding-devel@lists.sourceforge.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753557AbZBQWyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:54:39 -0500
In-Reply-To: <16929.1234904788@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 17 Feb 2009 13:06:28 -0800

> 	Putting the ipv6 bits into a different module might not help,
> either, because the "core" bonding code would still have the call to the
> ipv6 functions.  Unless there's some magic way to somehow know at
> runtime whether or not the ipv6 module is loaded, and only try to
> resolve those symbols if ipv6 is loaded.  That seems complicated.

This is a non-starter, as I described in one of my other replies.
