From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 15:38:46 -0500 (EST)
Message-ID: <20150115.153846.1450539700341201746.davem@davemloft.net>
References: <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC9AB0@AcuExch.aculab.com>
	<FC41C24E35F18A40888AACA1A36F3E418ADD011A@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, jacob.e.keller@intel.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbbAOUiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 15:38:50 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ADD011A@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Thu, 15 Jan 2015 15:01:42 +0000

> The dev_info() messages have the PCI device and function number in the string, so it's really not too hard to track down the resulting netdev port:
> Jan 13 15:46:55 snelson3-cup kernel: [621235.401627] i40e 0000:84:00.1: PHC enabled
> 
> Later messages use netdev_info() and have both the device number and the netdev name:
> Jan 13 15:46:56 snelson3-cup kernel: [621236.508868] i40e 0000:04:00.1 p261p2: NIC Link is Up 10 Gbps Full Duplex, Flow Control: None
> 
> Note that the driver name appears in both as well.

I think we should consistently provide the netdev name as soon as
register_netdevice() returns.

It is unwise for every driver to have their own private policy on
this.

Please change this back.
