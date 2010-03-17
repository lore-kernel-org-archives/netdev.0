From: David Miller <davem@davemloft.net>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 11:17:17 -0700 (PDT)
Message-ID: <20100317.111717.85209898.davem@davemloft.net>
References: <20100316.234100.133957798.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, netdev@vger.kernel.org, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51905
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693Ab0CQSQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 14:16:56 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Wed, 17 Mar 2010 11:57:59 -0600

> But then the driver build fails again when CONFIG_PM_RUNTIME is not set.
> 
> drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
> drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`

Ugh, can someone send me a fix for that?
