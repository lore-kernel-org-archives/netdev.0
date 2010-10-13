From: David Miller <davem@davemloft.net>
Subject: Re: bnx2 is spamming dmesg
Date: Wed, 13 Oct 2010 14:37:44 -0700 (PDT)
Message-ID: <20101013.143744.71127091.davem@davemloft.net>
References: <1287005434.8004.32.camel@keith-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: kmannth@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752065Ab0JMVhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:37:22 -0400
In-Reply-To: <1287005434.8004.32.camel@keith-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Keith Mannthey <kmannth@us.ibm.com>
Date: Wed, 13 Oct 2010 14:30:34 -0700

>   For the last couple of months (since at least 2.6.35 somewhere) I have
> been seeing 

It's not the bnx2 driver, it's the intel-iommu driver.

This is coming from a pr_debug() statement, so turn off
CONFIG_PCI_DEBUG to get rid of the "DEBUG" define that
gets added to the kernel build command line which causes
that line to print the message unconditionally.

