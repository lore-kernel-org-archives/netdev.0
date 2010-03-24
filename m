From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] netxen: added sanity check for pci map
Date: Wed, 24 Mar 2010 11:46:20 -0700 (PDT)
Message-ID: <20100324.114620.37223701.davem@davemloft.net>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
	<1269437363-2606-8-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932177Ab0CXSp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 14:45:57 -0400
In-Reply-To: <1269437363-2606-8-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) You're leaking the ioremap() mappings in this patch when one of
   them fails.

2) This is too many patches to be submitting to net-2.6 this late in
   the post-merge-window time period.  If you want some of these fixes
   in net-2.6 pick a small set of the most important ones and
   resubmit.

I'm tossing this whole series for now.
