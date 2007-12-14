From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ixgb: make sure jumbos stay enabled after reset
Date: Fri, 14 Dec 2007 16:13:17 -0500
Message-ID: <4762F1ED.2000708@garzik.org>
References: <20071214194829.15478.2510.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	matheos.worku@sun.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40462 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755129AbXLNVNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:13:20 -0500
In-Reply-To: <20071214194829.15478.2510.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Matheos Worku <matheos.worku@sun.com>
> 
> Currently a device reset (ethtool -r ethX) would cause the
> adapter to fall back to regular MTU sizes.
> 
> Signed-off-by: Matheos Worku <matheos.worku@sun.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb_main.c |   16 ++++++++++++++--
>  1 files changed, 14 insertions(+), 2 deletions(-)

applied #upstream-fixes


