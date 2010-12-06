From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix possible NULL pointer deference in
 shutdown path
Date: Mon, 06 Dec 2010 13:17:11 -0800 (PST)
Message-ID: <20101206.131711.189695399.davem@davemloft.net>
References: <20101202065447.13252.88901.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752423Ab0LFVQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:16:44 -0500
In-Reply-To: <20101202065447.13252.88901.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Dec 2010 22:54:53 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> After freeing the rings we were not zeroing out the ring count values.
> This patch now clears these counts correctly.
> 
> Reported-by: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

> ---
> 
>  0 files changed, 0 insertions(+), 0 deletions(-)

Whoa.  Some stacked-GIT problem or something like that?
Please check it out.
