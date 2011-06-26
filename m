From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC 46/72] ixp2000: Move the Radisys driver
Date: Sun, 26 Jun 2011 13:47:21 +0200
Message-ID: <20110626114721.GA19500@wantstofly.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Lennert Buytenhek <kernel@wantstofly.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:54515 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab1FZLrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 07:47:25 -0400
Content-Disposition: inline
In-Reply-To: <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 06:58:57AM -0700, Jeff Kirsher wrote:

> Move the Radisys driver into drivers/net/ethernet/radisys/ and
> make the necessary Kconfig and Makefile changes
> 
> CC: Lennert Buytenhek <kernel@wantstofly.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                        |    2 +-
>  drivers/net/Kconfig                                |    2 --
>  drivers/net/Makefile                               |    1 -
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/radisys/Kconfig               |   16 ++++++++++++++++
>  drivers/net/ethernet/radisys/Makefile              |    5 +++++
>  drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig |    2 +-
>  .../net/{ => ethernet/radisys}/ixp2000/Makefile    |    0

The ixp2000 is a series of Intel ARM SoCs, and the ENP2611 is a Radisys
PCI board based on the ixp2000 series (ixp2400), so it doesn't make
sense to put everything in the radisys/ directory.

If you insist on moving all drivers into vendor directories (I don't
like that idea at all -- are we going to rename directories and shuffle
stuff around every time vendor A buys vendor B or takes over one of
vendor B's products?), at least the core ixp2000 code should be under
intel/.
