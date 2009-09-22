From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix minor tx timeout bug
Date: Tue, 22 Sep 2009 14:14:19 -0700 (PDT)
Message-ID: <20090922.141419.65742024.davem@davemloft.net>
References: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbZIVVOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:14:00 -0400
In-Reply-To: <1253510439-28464-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 20 Sep 2009 22:20:38 -0700

> Fix minor bug in netdev tx timeout handling which could
> always lead to firmware reset instead of pci function reset.
> 
> netxen_nic_reset_context() requires __NX_RESETTING bit
> cleared.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
