From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver:
 vmxnet3
Date: Mon, 28 Sep 2009 17:08:21 -0700 (PDT)
Message-ID: <20090928.170821.124026517.davem@davemloft.net>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, jgarzik@pobox.com,
	anthony@codemonkey.ws, chrisw@sous-sol.org, greg@kroah.com,
	akpm@linux-foundation.org,
	virtualization@lists.linux-foundation.org, pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632AbZI2AID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 20:08:03 -0400
In-Reply-To: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Mon, 28 Sep 2009 16:56:45 -0700

> +       uint32_t rxdIdx:12;    /* Index of the RxDesc */

Don't use uint32_t et al. sized types, use "u32" and friends
throughout.
