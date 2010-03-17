From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 21:34:55 +0100
Message-ID: <201003172134.55361.rjw@sisk.pl>
References: <20100316.234100.133957798.davem@davemloft.net> <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com> <20100317.111717.85209898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47087 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab0CQUcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 16:32:09 -0400
In-Reply-To: <20100317.111717.85209898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 March 2010, David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Wed, 17 Mar 2010 11:57:59 -0600
> 
> > But then the driver build fails again when CONFIG_PM_RUNTIME is not set.
> > 
> > drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
> > drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`
> 
> Ugh, can someone send me a fix for that?

I will in a while.
