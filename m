From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/8] bnx2: Put rx ring variables in a separate struct.
Date: Thu, 19 Jun 2008 16:39:57 -0700 (PDT)
Message-ID: <20080619.163957.42443688.davem@davemloft.net>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
	<1213835132-5698-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753076AbYFSXj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:39:57 -0400
In-Reply-To: <1213835132-5698-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 18 Jun 2008 17:25:26 -0700

> In preparation for multi-ring support, rx ring variables are now put
> in a separate bnx2_rx_ring_info struct.  With MSI-X, we can support
> multiple rx rings.
> 
> The functions to allocate/free rx memory and to initialize rx rings
> are now modified to handle multiple rings.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied to net-next-2.6
