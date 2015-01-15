From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 18:12:34 -0500 (EST)
Message-ID: <20150115.181234.1832448766968509279.davem@davemloft.net>
References: <FC41C24E35F18A40888AACA1A36F3E418ADD011A@fmsmsx115.amr.corp.intel.com>
	<20150115.153846.1450539700341201746.davem@davemloft.net>
	<FC41C24E35F18A40888AACA1A36F3E418ADD4215@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, jacob.e.keller@intel.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbbAOXMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 18:12:37 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ADD4215@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Thu, 15 Jan 2015 22:44:48 +0000

> Yes, the driver should print the unvarnished truth.  What's
> frustrating about UDEV is that it ends up making the driver look
> like it is confused and/or lying in the log messages.  We'd prefer
> to minimize this unnecessary user-confusion where possible.

The only way to resolve this is to have some kind of synchronized
event wherein when a device is instantiated we get userland to
assign the final name before the device has any visibility anywhere
(basically before register_netdevice() puts the device into the
hashes where it can be found).
