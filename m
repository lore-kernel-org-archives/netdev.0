From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 28 Feb 2011 19:12:50 +0000
Message-ID: <1298920370.2569.15.camel@bwh-desktop>
References: <1298917347.2569.5.camel@bwh-desktop>
	 <20110228.110655.71121452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, santwona.behera@sun.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:39072 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab1B1TMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 14:12:54 -0500
In-Reply-To: <20110228.110655.71121452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 11:06 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 28 Feb 2011 18:22:26 +0000
> 
> > This structure was accidentally defined such that its layout can
> > differ between 32-bit and 64-bit processes.  Add compat structure
> > definitions and functions to copy from/to user-space with the
> > necessary adjustments.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Please implement this via the proper contextual compat ioctl handling
> in net/socket.c
> 
> Using is_compat_task() is heavily discouraged.

This is going to be even more horrible.  But I'll try it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

