From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_newemac: Fix possible lockup on close
Date: Fri, 23 Nov 2007 20:52:25 -0500
Message-ID: <474783D9.2070700@pobox.com>
References: <20071120035134.970DCDDE9E@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51356 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044AbXKXBw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:52:28 -0500
In-Reply-To: <20071120035134.970DCDDE9E@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> It's a bad idea to call flush_scheduled_work from within a
> netdev->stop because the linkwatch will occasionally take the
> rtnl lock from a workqueue context, and thus that can deadlock.
> 
> This reworks things a bit in that area to avoid the problem.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 

applied #upstream-fixes (2.6.24-rc)

