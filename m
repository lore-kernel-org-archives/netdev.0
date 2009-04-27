From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Add bnx2 iSCSI support.
Date: Mon, 27 Apr 2009 03:09:13 -0700 (PDT)
Message-ID: <20090427.030913.247641254.davem@davemloft.net>
References: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, anilgv@broadcom.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751152AbZD0KJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:09:20 -0400
In-Reply-To: <1240532563-23048-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 23 Apr 2009 17:22:39 -0700

> New Broadcom iSCSI driver for review.  Compared to the last 
> version we posted in 2008, we've changed it to use a separate
> and private MAC address/IP address for iSCSI.  We are creating
> a UIO interface to handle the non-offloaded packets such as
> ARP, etc. in user space.  Thanks.

I'm fine with the drivers/net portions.

We have to figure out how to merge this though :-)

I'm happy with it going in via the SCSI tree or similar, all of it.
So feel free to add:

Acked-by: David S. Miller <davem@davemloft.net>

We'll sort out the merge issues as needed.
