From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: Fix NETDEV_UP event processing.
Date: Fri, 02 Oct 2009 11:03:46 -0700 (PDT)
Message-ID: <20091002.110346.35364860.davem@davemloft.net>
References: <1254464254-32005-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753599AbZJBSD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:03:26 -0400
In-Reply-To: <1254464254-32005-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 1 Oct 2009 23:17:34 -0700

> This fixes the problem of not handling the NETDEV_UP event properly
> during hot-plug or modprobe of bnx2 after cnic.  The handling was
> skipped by mistakenly using "else if" to check for the event.
> 
> Also update version to 2.0.1.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied, thanks Michael.
