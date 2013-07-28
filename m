From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] ixgbe: Fix Tx Hang issue with lldpad on 82598EB
Date: Sun, 28 Jul 2013 13:17:44 -0700 (PDT)
Message-ID: <20130728.131744.570277321380457057.davem@davemloft.net>
References: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Jul 2013 05:46:35 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch fixes an issue with the 82598EB device, where lldpad is causing Tx
> Hangs on the card as soon as it attempts to configure DCB for the device. The
> adapter will continually Tx hang and reset in a loop.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Cc: Stable <stable@vger.kernel.org>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Jack Morgan <jack.morgan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
