From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ixgb: enable sun hardware support for broadcom phy
Date: Mon, 17 Dec 2007 20:17:49 -0500
Message-ID: <47671FBD.4010402@garzik.org>
References: <20071214194829.15478.2510.stgit@localhost.localdomain> <20071214194836.15478.85555.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	matheos.worku@sun.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34156 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbXLRBRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:17:52 -0500
In-Reply-To: <20071214194836.15478.85555.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Matheos Worku <matheos.worku@sun.com>
> 
> Implement support for a SUN-specific PHY.
> 
> SUN provides a modified 82597-based board with their own
> PHY that works with very little modification to the code. This
> patch implements this new PHY which is identified by the
> subvendor device ID. The device ID of the adapter remains
> the same.
> 
> Signed-off-by: Matheos Worku <matheos.worku@sun.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb_hw.c   |   82 +++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/ixgb/ixgb_hw.h   |    3 +-
>  drivers/net/ixgb/ixgb_ids.h  |    4 ++
>  drivers/net/ixgb/ixgb_main.c |   10 +++--
>  4 files changed, 91 insertions(+), 8 deletions(-)

applied #upstream


