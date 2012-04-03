From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/5] e1000: Support RX-ALL flag.
Date: Tue, 03 Apr 2012 18:19:29 -0400 (EDT)
Message-ID: <20120403.181929.1415344300667992480.davem@davemloft.net>
References: <1333491489-29933-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1333491489-29933-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187Ab2DCWTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:19:34 -0400
In-Reply-To: <1333491489-29933-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Apr 2012 15:18:06 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> This allows the NIC to receive errored frames (bad FCS, etc)
> and pass them up the stack.  This can be useful when using
> sniffers.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This is not a bug fix, therefore it's not appropriate for 'net'
