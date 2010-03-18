From: David Miller <davem@davemloft.net>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 23:12:41 -0700 (PDT)
Message-ID: <20100317.231241.226771084.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com>
	<20100317.111717.85209898.davem@davemloft.net>
	<201003172339.15494.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353Ab0CRGMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 02:12:19 -0400
In-Reply-To: <201003172339.15494.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Wed, 17 Mar 2010 23:39:15 +0100

> Subject: Net / e1000e: Fix build issue introduced by runtime PM patch
> 
> The recent PCI runtime PM patch broke build for CONFIG_PM_RUNTIME
> and CONFIG_PM_SLEEP undefined.  Fix that by moving the PM callbacks
> under suitable #ifdefs.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied, thanks Rafael.
