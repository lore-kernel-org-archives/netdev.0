From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/9] Add TSO support
Date: Tue, 13 May 2008 01:17:46 -0400
Message-ID: <4829247A.5020407@pobox.com>
References: <20080507114121.GL2217@solarflare.com> <20080507115112.GM2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbYEMFRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:17:48 -0400
In-Reply-To: <20080507115112.GM2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The SFC4000 controller does not have hardware support for TSO, and the
> core GSO code incurs a high cost in allocating and freeing skbs.  This
> TSO implementation uses lightweight packet header structures and is
> substantially faster.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c        |    4 +-
>  drivers/net/sfc/ethtool.c    |   27 ++
>  drivers/net/sfc/net_driver.h |   14 +
>  drivers/net/sfc/tx.c         |  664 ++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 708 insertions(+), 1 deletions(-)

applied 1-9, with two comments:

1) your subject line is missing a useful prefix.  see
http://linux.yyz.us/patch-format.html

2) normally TSO addition would not be permitting during the 
bug-fixes-only phase of the kernel development (2.6.26-rc is current), 
but since the driver is new, it is reasonable because there can be no 
regressions

