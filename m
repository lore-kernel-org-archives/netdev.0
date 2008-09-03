From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: initialize interrupt throttle rate
Date: Wed, 03 Sep 2008 09:27:04 -0400
Message-ID: <48BE90A8.4090601@garzik.org>
References: <20080828010432.7539.735.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, stable@kernel.org,
	andy@greyhouse.net, jesse.brandeburg@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbYICN1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:27:09 -0400
In-Reply-To: <20080828010432.7539.735.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> 
> This commit dropped the setting of the default interrupt throttle rate.
> 
> commit 021230d40ae0e6508d6c717b6e0d6d81cd77ac25
> Author: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
> Date:   Mon Mar 3 15:03:45 2008 -0800
> 
>     ixgbe: Introduce MSI-X queue vector code
> 
> The following patch adds it back.  Without this the default value of 0
> causes the performance of this card to be awful.  Restoring these to the
> default values yields much better performance.
> 
> This regression has been around since 2.6.25.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: stable@kernel.org [2.6.25 and later]
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)

applied


