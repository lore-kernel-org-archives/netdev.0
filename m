From: David Miller <davem@davemloft.net>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Tue, 23 Mar 2010 23:33:23 -0700 (PDT)
Message-ID: <20100323.233323.93371615.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4ADAB2A@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754816Ab0CXGdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:33:00 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4ADAB2A@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Tue, 23 Mar 2010 12:28:08 -0600

> Bisecting points to this patch:
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
> 
> And I confirmed that the issue goes away after reverting it.
> 
> Steps to reproduce:
> 1. Load the driver and configure IPv6 address.
> 2. Run ethtool diag:
> ethtool -t eth0
> 
> 3. If this doesn't brake it try again, or just do ifdown/up. Other operations on the interface will eventually panic the system:

Stephen please fix this, thanks.
