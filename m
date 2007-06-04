From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [1/5][BNX2]: Fix netdev watchdog on 5708.
Date: Mon, 4 Jun 2007 19:38:43 -0400
Message-ID: <20070604233843.GA31462@havoc.gtf.org>
References: <1181001603.5275.12.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andy@greyhouse.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:38536 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494AbXFDXio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:38:44 -0400
Content-Disposition: inline
In-Reply-To: <1181001603.5275.12.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 05:00:03PM -0700, Michael Chan wrote:
> [BNX2]: Fix netdev watchdog on 5708.
> 
> There's a bug in the driver that only initializes half of the context
> memory on the 5708.  Surprisingly, this works most of the time except
> for some occasional netdev watchdogs when sending a lot of 64-byte
> packets.  The fix is to add the missing code to initialize the 2nd
> halves of all context memory.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK patch 1, and 3-5


