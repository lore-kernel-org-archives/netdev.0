From: David Miller <davem@davemloft.net>
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to
 -mmtree
Date: Wed, 03 Sep 2008 01:24:32 -0700 (PDT)
Message-ID: <20080903.012432.75866225.davem@davemloft.net>
References: <1220398304.32688.163.camel@bodhitayantram.eng.vmware.com>
	<36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com>
	<1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, chrisl@vmware.com,
	akpm@linux-foundation.org, arvidjaar@mail.ru,
	bruce.w.allan@intel.com, jeff@garzik.org,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com,
	peter.p.waskiewicz.jr@intel.com, pratap@vmware.com,
	netdev@vger.kernel.org, mm-commits@vger.kernel.org
To: zach@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44772
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751239AbYICIYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 04:24:39 -0400
In-Reply-To: <1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zachary Amsden <zach@vmware.com>
Date: Wed, 03 Sep 2008 01:17:25 -0700

> Thus, the obvious answer to me is ... LOCK AROUND EEPROM READS AND
> WRITES now and figure out if there are deeper issues due to network
> layer and E1000 complexities later, but ELIMINATE THE CATASTROPHIC
> FAILURES ASAP.

I totally agree with Zach here.

The fact that we are still masterbating about this bug and a fix
isn't in the tree is absolutely rediculious.
