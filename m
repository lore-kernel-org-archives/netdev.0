From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix coherent dma mask setting
Date: Sun, 02 Aug 2009 12:31:46 -0700 (PDT)
Message-ID: <20090802.123146.188668175.davem@davemloft.net>
References: <1249198576-11389-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753489AbZHBTbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:31:38 -0400
In-Reply-To: <1249198576-11389-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun,  2 Aug 2009 00:36:16 -0700

> Change default dma mask for NX3031 to 39 bit with ability
> to update it to 64-bit (if firmware indicates support). Old
> code was restricting it under 4GB (32-bit), sometimes causing
> failure to allocate descriptor rings on heavily populated
> system. NX2031 based NICs will still get 32-bit coherent mask.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
