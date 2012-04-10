From: David Miller <davem@davemloft.net>
Subject: Re: Please revert removal of /sys/class/net/*/features
Date: Tue, 10 Apr 2012 14:27:46 -0400 (EDT)
Message-ID: <20120410.142746.177154176524267450.davem@davemloft.net>
References: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab2DJS2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:28:52 -0400
In-Reply-To: <20120410110851.5690739c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Apr 2012 11:08:51 -0700

> This commit needs to be reverted. It removed an available sysfs file, and sysfs
> files are part of the ABI. It caused a bug in our current release of Vyatta because
> the shell script was using the sysfs file to see if VLAN was supported on a device.
> 
> An API maybe redundant, but you can't just remove it.

I think it's more about representability with an expanded
netdev_features_t type.
