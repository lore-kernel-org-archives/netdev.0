From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 4/5] NetXen: Fix ping issue
Date: Wed, 06 Jun 2007 13:22:41 -0500
Message-ID: <1181154161.25390.53.camel@wendyx.austin.ibm.com>
References: <200706011116.l51BGPZf004774@dut39.unminc.com>
	 <4662E375.5020409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mithlesh Thukral <mithlesh@netxen.com>, netdev@vger.kernel.org,
	amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41253 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755723AbXFFSWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 14:22:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l56HK8cC028143
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 13:20:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56IMgaB477312
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 14:22:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56IMgsl031556
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 14:22:42 -0400
In-Reply-To: <4662E375.5020409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-06-03 at 11:51 -0400, Jeff Garzik wrote:
> Mithlesh Thukral wrote:
> > NetXen: Fix initialization and subsequent ping issue
> > This patch will fix the initialization and ping issues seen on
> > certain PPC architecture blades.
> > 
> > Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> > Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
> > ---
> > 
> >  drivers/net/netxen/netxen_nic_main.c |    7 +++++++
> >  drivers/net/netxen/netxen_nic_niu.c  |    8 ++------
> >  2 files changed, 9 insertions(+), 6 deletions(-)
> 
> Again, your patch description is useless.
> 
> You should describe the problem being fixed, and how/why the changes 
> seen in the patch actually fix the issue.
> 
Hi Jeff,

Ping problem description:
After we moved up netxen adapter's firmware to 3.4.19, we saw this ping
problem on x/pBlade.  After configured interface up, ping -c 1
10.10.10.10 failed. Netxen adapter couldn't accept ARP broadcast packet
somehow. If I manually added MAC address in the ARP table, then ping
start working.

netxen adapter should finish initilization after system boot. But on
some platform, looks netxen adapter didn't initilization correctly after
system boot up, so have to re-load the firmware again in probe routine.
Also re-initilization netxen_config_0 and netxen_config_1 registers.

Let me know if you have any question for this patch.

Thanks
Wendy Xiong





