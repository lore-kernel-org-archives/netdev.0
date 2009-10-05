From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/9] vxge: Modify
 __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged
 function.
Date: Mon, 05 Oct 2009 02:20:17 -0700 (PDT)
Message-ID: <20091005.022017.252887922.davem@davemloft.net>
References: <Pine.GSO.4.10.10910050503530.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932353AbZJEJUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:20:23 -0400
In-Reply-To: <Pine.GSO.4.10.10910050503530.2346-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:06:06 -0400 (EDT)

> - vxge driver was assuming function-0 is always the privilaged function. Now that
>   restriction has been removed any function can act as a privilaged function.
> 
> - This patch modifies the __vxge_hw_device_is_privilaged routine to not assume
>   function-0 as the privileged function.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> ---
> diff -urpN orig//drivers/net/vxge/vxge-config.c patch1//drivers/net/vxge/vxge-config.c
> --- orig//drivers/net/vxge/vxge-config.c	2009-09-03 22:39:48.000000000 -0700
> +++ patch1//drivers/net/vxge/vxge-config.c	2009-09-03 23:11:24.000000000 -0700

You can't have the double slash there in your paths, this
gets interpreted as "/drivers/net/vxge/vxge-config.c" by
all the patch applying tools.

Please "-p1" root your patches properly as described in
linux/Documentation/SubmittingPatches

You'll need to resubmit your entire patch set with this
fixed up.

Thanks.

