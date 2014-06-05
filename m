From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 02/14] i40e: Allow disabling of DCB via debugfs
Date: Thu, 05 Jun 2014 00:56:32 -0700 (PDT)
Message-ID: <20140605.005632.2052466271313574330.davem@davemloft.net>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1401954567-13557-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: neerav.parikh@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaFEH4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 03:56:33 -0400
In-Reply-To: <1401954567-13557-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  5 Jun 2014 00:49:15 -0700

> From: Neerav Parikh <neerav.parikh@intel.com>
> 
> Diagnostic and traffic generator tests fail when DCB is enabled.
> This is due to the fact that when DCB is enabled the Tx packets
> from the adapter are VLAN tagged and these tests are not expecting
> an extra tag in the packets.
> 
> So, allow disabling of the DCB flag via debugfs so that these tests
> can proceed.
> 
> New debugfs commands
> "dcb off" -- Disable DCB tagging; only works when in single TC mode
> "dcb on" -- Re-enable DCB tagging
> 
> Change-ID: I14cc894e1cbf8a3b8ecfba4a3886f9861e7678ed
> Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Please define a portable, generic, interface for this that other
drivers can make use of.

And in the future, generally speaking, please stop plopping every
diagnostic knob you come up with into debugfs by default.

Thank you.
