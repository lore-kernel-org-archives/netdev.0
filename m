From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 15:43:01 -0400
Message-ID: <1151005381.5392.108.camel@jzny2>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:44442 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932641AbWFVTnE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 15:43:04 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtV52-00038q-7X
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 15:43:08 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1150990041.3040.6.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 10:27 -0500, Steve Wise wrote:

> 
> The in-kernel Infiniband subsystem needs to know when certain events
> happen.  For example, if the mac address of a neighbour changes.  Any
> rdma devices that are using said neighbour need to be notified of the
> change.  You are asking that I extend the netlink facility (if
> necessary) to provide this functionality.  
> 

No - what these 2 gents are saying was these events and infrastructure
already exist. If there are some events that dont and you need to extend
what already exists. Your patch was a serious reinvention of the wheel
(and in the case of the neighbor code looking very wrong).
As an example, search for NETDEV_CHANGEADDR,NETDEV_CHANGEMTU etc.
Actually you are probably making this too complicated. Listen to events
in user space and tell infiniband from user space.

cheers,
jamal

