From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND] [NET-NEXT PATCH 3/3] e1000e: add support for new 82574L
 part
Date: Wed, 03 Sep 2008 10:09:19 -0400
Message-ID: <48BE9A8F.2070003@garzik.org>
References: <20080827013611.5716.7376.stgit@jtkirshe-mobile.jf.intel.com> <20080827013653.5716.34378.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, andy@greyhouse.net,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43739 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754364AbYICOJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:09:23 -0400
In-Reply-To: <20080827013653.5716.34378.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This new part has the same feature set as previous parts with the addition
> of MSI-X support.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c   |  153 ++++++++++++++--
>  drivers/net/e1000e/defines.h |   13 +
>  drivers/net/e1000e/e1000.h   |   28 +++
>  drivers/net/e1000e/es2lan.c  |    2 
>  drivers/net/e1000e/ethtool.c |   38 +++-
>  drivers/net/e1000e/hw.h      |   11 +
>  drivers/net/e1000e/ich8lan.c |   18 ++
>  drivers/net/e1000e/lib.c     |    7 -
>  drivers/net/e1000e/netdev.c  |  409 +++++++++++++++++++++++++++++++++++++-----
>  drivers/net/e1000e/param.c   |   27 +++
>  drivers/net/e1000e/phy.c     |  109 +++++++++++
>  11 files changed, 738 insertions(+), 77 deletions(-)

applied


