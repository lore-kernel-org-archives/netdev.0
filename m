From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,v2] Re: e1000e: why does
 pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Thu, 20 Aug 2009 23:52:19 -0700 (PDT)
Message-ID: <20090820.235219.74114618.davem@davemloft.net>
References: <200908210829.10471.elendil@planet.nl>
	<4A8E3FC1.50201@redhat.com>
	<200908210848.39377.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dfeng@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: elendil@planet.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932088AbZHUGwJ@vger.kernel.org>
In-Reply-To: <200908210848.39377.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frans Pop <elendil@planet.nl>
Date: Fri, 21 Aug 2009 08:48:38 +0200

> From: Frans Pop <elendil@planet.nl>
> Subject: net: Don't report an error if devices don't support AER
> 
> The only error returned by pci_{en,dis}able_pcie_error_reporting() is
> -EIO which simply means that Advanced Error Reporting is not supported.
> There is no need to report that, so remove the error check from e1001e,
> igb and ixgbe.
> 
> Signed-off-by: Frans Pop <elendil@planet.nl>

Intel folks, just let me know what you want me to do with this,
if anything.

Thanks.
