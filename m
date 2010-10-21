From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Revert d88dca79d3852a3623f606f781e013d61486828a
Date: Thu, 21 Oct 2010 04:11:39 -0700 (PDT)
Message-ID: <20101021.041139.241440082.davem@davemloft.net>
References: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
	<1287659176-14504-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, luca@llucax.com.ar
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756860Ab0JULLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:11:16 -0400
In-Reply-To: <1287659176-14504-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nhorman@tuxdriver.com
Date: Thu, 21 Oct 2010 07:06:16 -0400

> From: Neil Horman <nhorman@tuxdriver.com>
> 
> TIPC needs to have its endianess issues fixed.  Unfortunately, the format of a
> subscriber message is passed in directly from user space, so requiring this
> message to be in network byte order breaks user space ABI.  Revert this change
> until such time as we can determine how to do this in a backwards compatible
> manner.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable.
