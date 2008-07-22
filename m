From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: remove device ID for unsupported device
Date: Tue, 22 Jul 2008 19:31:19 -0400
Message-ID: <48866DC7.5000801@garzik.org>
References: <20080712003458.21801.63058.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, gregkh@suse.de, davem@davemloft.net,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48076 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758827AbYGVXb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:31:27 -0400
In-Reply-To: <20080712003458.21801.63058.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The ixgbe driver was untested with device ID 8086:10c8 but still advertises
> support.  Currently if this device is present in the system when the driver
> is loaded, the system will panic.
> Remove this device ID until full support can be tested with available
> hardware.  This patch is necessary for 2.6.24, 2.6.25 and 2.6.26
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)

applied


