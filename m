From: Nicolas Pitre <nico@cam.org>
Subject: Re: [patch 32/41] lockdep: fix smc91x
Date: Wed, 16 Aug 2006 15:37:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608161526260.3494@localhost.localdomain>
References: <200608150600.k7F60KYL012708@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org, rmk+lkml@arm.linux.org.uk,
	rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:14189 "EHLO
	relais.videotron.ca") by vger.kernel.org with ESMTP id S932193AbWHPTiB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 15:38:01 -0400
Received: from xanadu.home ([74.56.106.175]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java System Messaging Server 6.2-2.05 (built Apr 28 2005))
 with ESMTP id <0J4300516VUXJJ60@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 16 Aug 2006 15:37:45 -0400 (EDT)
In-reply-to: <200608150600.k7F60KYL012708@shell0.pdx.osdl.net>
To: Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006, akpm@osdl.org wrote:

> From: Russell King <rmk+lkml@arm.linux.org.uk>
> 
> When booting using root-nfs, I'm seeing (independently) two lockdep dumps
> in the smc91x driver.  The patch below fixes both.  Both dumps look like
> real locking issues.
> 
> Nico - please review and ack if you think the patch is correct.

The lock validator is rightfully complaining and the patch is correct.

Acked-by: Nicolas Pitre <nico@cam.org>


Nicolas
