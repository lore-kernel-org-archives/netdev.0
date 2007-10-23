From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support to
 NEW EMAC.
Date: Tue, 23 Oct 2007 11:17:06 -0500
Message-ID: <20071023111706.2af5735d@weaponx.rchland.ibm.com>
References: <20071015175717.GA4602@ru.mvista.com>
	<4713B10B.5000607@garzik.org>
	<20071023102035.6d35d3fe@weaponx.rchland.ibm.com>
	<38505C5B-4252-4AA7-B4F5-6B5267A6DBAA@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Valentine Barshak <vbarshak@ru.mvista.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44954 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbXJWQ3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 12:29:37 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9NGTblS010174
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 12:29:37 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9NGQD2L095168
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 10:29:36 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9NGH8Ir004538
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 10:17:09 -0600
In-Reply-To: <38505C5B-4252-4AA7-B4F5-6B5267A6DBAA@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Oct 2007 11:13:48 -0500
Kumar Gala <galak@kernel.crashing.org> wrote:

> 
> On Oct 23, 2007, at 10:20 AM, Josh Boyer wrote:
> 
> > On Mon, 15 Oct 2007 14:27:23 -0400
> > Jeff Garzik <jeff@garzik.org> wrote:
> >
> >> Valentine Barshak wrote:
> >>> This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW  
> >>> EMAC driver.
> >>> These PHY chips are used on PowerPC 440EPx boards.
> >>> The PHY code is based on the previous work by Stefan Roese  
> >>> <sr@denx.de>
> >>>
> >>> Signed-off-by: Stefan Roese <sr@denx.de>
> >>> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> >>> ---
> 
> You guys should really look at moving emac over to the phylib so we  
> don't have to duplicate drivers for the same phys all over the place :)

Yes, we should.  It's on the list.  Just not for 2.6.24 since it's way
too late.

josh
