From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/2] Intel Wired LAN Driver Updates
Date: Wed, 15 Jan 2014 21:49:03 -0800 (PST)
Message-ID: <20140115.214903.605116883676335215.davem@davemloft.net>
References: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbaAPFtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 00:49:11 -0500
In-Reply-To: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Wed, 15 Jan 2014 17:38:39 -0800

> This series contains several updates from Alex to ixgbe.
> 
> To avoid head of line blocking in the event a VF stops cleaning Rx descriptors
> he makes sure QDE bits are set for a VF before the Rx queues are enabled.
> 
> To avoid a situation where the head write-back registers can remain set ofter 
> the driver is unloaded he clears them on a VF reset.

Series applied, thanks Aaron.
