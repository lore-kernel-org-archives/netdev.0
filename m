From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e/igb/ixgbe: Don't report an error if
 devices don't support AER
Date: Fri, 02 Oct 2009 10:04:19 -0700 (PDT)
Message-ID: <20091002.100419.171120643.davem@davemloft.net>
References: <20091002071542.5072.23381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, elendil@planet.nl
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42219
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756745AbZJBRD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 13:03:59 -0400
In-Reply-To: <20091002071542.5072.23381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 02 Oct 2009 00:15:48 -0700

> From: Frans Pop <elendil@planet.nl>
> 
> The only error returned by pci_{en,dis}able_pcie_error_reporting() is
> -EIO which simply means that Advanced Error Reporting is not supported.
> There is no need to report that, so remove the error check from e1000e,
> igb and ixgbe.
> 
> Signed-off-by: Frans Pop <elendil@planet.nl>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
