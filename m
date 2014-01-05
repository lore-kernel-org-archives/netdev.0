From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v5 04/17] i40e: Populate and check pci bus speed and
 width
Date: Sat, 04 Jan 2014 19:49:42 -0500 (EST)
Message-ID: <20140104.194942.638270130526105275.davem@davemloft.net>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388815005-23166-5-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAErSpo5fHrxTqhU+eHnB9oVwvghU=m5p=ANfkJQU0kOt9Tryww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, catherine.sullivan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com, jacob.e.keller@intel.com
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbaAEAto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 19:49:44 -0500
In-Reply-To: <CAErSpo5fHrxTqhU+eHnB9oVwvghU=m5p=ANfkJQU0kOt9Tryww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sat, 4 Jan 2014 14:04:30 -0700

> I don't see anything device-specific here.  This all looks to be
> generic per the PCIe spec, without anything specific to the i40e.  In
> fact, this new code looks almost identical to what Jacob added to
> ixgbe with e027d1aec4bb, except that Jacob's code checks the whole
> path up to the root, not just the single link leading to the device.
> 
> Since you're doing basically the same thing, it'd be nice if the code
> looked basically the same.

Agreed.

I'm going to pull from Jeff's tree meanwhile and ask that this consolidation
happens as follow-up changes.

Thanks.
