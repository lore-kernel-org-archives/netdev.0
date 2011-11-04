From: David Miller <davem@redhat.com>
Subject: Re: [net] i825xx:xscale:8390:freescale: Fix Kconfig dependancies
Date: Fri, 04 Nov 2011 17:41:59 -0400 (EDT)
Message-ID: <20111104.174159.1262489521924521081.davem@redhat.com>
References: <1320229852-18161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab1KDVmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 17:42:01 -0400
In-Reply-To: <1320229852-18161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  2 Nov 2011 03:30:52 -0700

> i825xx and xscale are "sub" Kconfigs to NET_VENDOR_INTEL, so
> NET_VENDOR_INTEL should contain ALL the dependencies of the
> "sub" Kconfigs.
> 
> Same with 8390 is a "sub" Kconfig to NET_VENDOR_NATSEMI, so
> NET_VENDOR_NATSEMI needs to contains ALL the dependencies.
> 
> Freescale Kconfig only had fs_enet as a sub Kconfig, and already
> contained the needed dependencies, just cleaned up the dependencies.
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, but:

> +		   XTENSA_PLATFORM_XT2000 || ZORRO
> +		   
>  	---help---

I removed that extraneous white-space-only line before "--help--"
