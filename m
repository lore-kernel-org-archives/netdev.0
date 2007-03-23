From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Revert "ucc_geth: returns NETDEV_TX_BUSY when BD ring
 is full"
Date: Fri, 23 Mar 2007 01:50:11 -0400
Message-ID: <46036A93.9070506@garzik.org>
References: <45FE0A4A.20402@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.barkowski@freescale.com
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60452 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753193AbXCWFuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:50:13 -0400
In-Reply-To: <45FE0A4A.20402@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> This reverts commit 18babd38547a042a4bfd4154a014d1ad33373eb0.
> 
> Michael Barkowski points out that it's wrong, and I agree.  The
> patch causes a problem rather than fixes one after another
> patch "ucc_geth: Fix BD processing" was applied.  Before that
> patch, current packet should be blocked.  However after the patch
> current packet is ok and we only need to block next.
> 
> Reported-by: Michael Barkowski <michael.barkowski@freescale.com>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> Sorry for the mistake I made.
> 
> drivers/net/ucc_geth.c |    3 +--
> 1 files changed, 1 insertions(+), 2 deletions(-)

applied


