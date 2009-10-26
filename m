From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/5] e1000e: allow for swflag to be held over
 consecutive PHY accesses
Date: Mon, 26 Oct 2009 16:17:27 -0700 (PDT)
Message-ID: <20091026.161727.75083296.davem@davemloft.net>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
	<20091026212401.9682.51970.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754669AbZJZXRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:17:04 -0400
In-Reply-To: <20091026212401.9682.51970.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:24:02 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> PCH-based parts (82577/82578) and some ICH8-based parts (82566) need to
> hold the swflag (sw/fw/hw hardware semaphore) over consecutive PHY accesses
> in order to perform sw-driven PHY configuration during initialization to
> workaround known hardware issues (see follow-on patch).  This patch
> provides new PHY read/write functions (and function pointers) that will
> allow accessing the PHY registers assuming the swflag has already been
> acquired.  The actual PHY register access code has moved into helper
> functions that are called with a flag indicating whether or not the swflag
> has already been acquired and acquires/releases it if not.
> 
> The functions called from within the updated PHY access functions had to be
> updated to assume the swflag was already acquired, and other functions that
> called those functions were also updated to acquire/release the swflag.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
