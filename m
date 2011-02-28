From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 28 Feb 2011 11:06:55 -0800 (PST)
Message-ID: <20110228.110655.71121452.davem@davemloft.net>
References: <1298917347.2569.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, santwona.behera@sun.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753116Ab1B1TGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 14:06:18 -0500
In-Reply-To: <1298917347.2569.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 28 Feb 2011 18:22:26 +0000

> This structure was accidentally defined such that its layout can
> differ between 32-bit and 64-bit processes.  Add compat structure
> definitions and functions to copy from/to user-space with the
> necessary adjustments.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Please implement this via the proper contextual compat ioctl handling
in net/socket.c

Using is_compat_task() is heavily discouraged.
