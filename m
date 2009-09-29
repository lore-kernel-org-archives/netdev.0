From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] [PATCH 2.6.31-rc9] net: VMware virtual Ethernet
 NIC driver: vmxnet3
Date: Mon, 28 Sep 2009 18:17:02 -0700 (PDT)
Message-ID: <20090928.181702.41922043.davem@davemloft.net>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
	<20090929002207.GB31372@kroah.com>
	<1254185499.13456.40.camel@ank32.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
	anthony@codemonkey.ws, akpm@linux-foundation.org, jgarzik@pobox.com
To: akataria@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753734AbZI2BQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 21:16:44 -0400
In-Reply-To: <1254185499.13456.40.camel@ank32.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alok Kataria <akataria@vmware.com>
Date: Mon, 28 Sep 2009 17:51:39 -0700

> As a side note, were there any changes in the networking API's, that we
> should look out for in the merge cycle ?
> If not I think the rebase should be pretty trivial.

Just off the top of my head, the return type of the driver transmit
function was changed to netdev_tx_t, for one thing.

But there were likely numerous others.  You'll have to check.
