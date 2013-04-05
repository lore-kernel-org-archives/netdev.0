From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: fix registration order of driver and DCA
 nofitication
Date: Fri, 05 Apr 2013 00:50:27 -0400 (EDT)
Message-ID: <20130405.005027.1161499904683364388.davem@davemloft.net>
References: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1365043854-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  3 Apr 2013 19:50:54 -0700

> From: Jakub Kicinski <jakub.kicinski@intel.com>
> 
> ixgbe_notify_dca cannot be called before driver registration
> because it expects driver's klist_devices to be allocated and
> initialized. While on it make sure debugfs files are removed
> when registration fails.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
