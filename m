From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch 089/181] Blackfin: on-chip ethernet MAC controller
 driver
Date: Sun, 6 May 2007 20:40:41 -0700
Message-ID: <20070506204041.db0ff08a.randy.dunlap@oracle.com>
References: <200705062150.l46LoVWQ024648@shell0.pdx.osdl.net>
	<463E70D8.6000403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	bryan.wu@analog.com, netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58719 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbXEGDgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 23:36:35 -0400
In-Reply-To: <463E70D8.6000403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 06 May 2007 20:20:40 -0400 Jeff Garzik wrote:

> akpm@linux-foundation.org wrote:
> > From: "Wu, Bryan" <bryan.wu@analog.com>
> > 
> > This patch implements the driver necessary use the Analog Devices
> > Blackfin processor's on-chip ethernet MAC controller.
> > 
> > Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/Kconfig    |   44 +
> >  drivers/net/Makefile   |    1 
> >  drivers/net/bfin_mac.c |  981 +++++++++++++++++++++++++++++++++++++++
> >  drivers/net/bfin_mac.h |  147 +++++
> >  4 files changed, 1173 insertions(+)
> 
> WTF?
> 
> Why are new network drivers not going to me, netdev, and/or DaveM?

because people are dumping Everything to lkml :(

> Something is really broken here.  What is it?

Use netdev, linux-scsi, linux-ide, linux-usb-devel, linux-ieee1394,
etc., instead of one-list-fits-all.


> I NAK this driver purely on the basis of lack of review.

Yep.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
