From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] bnx2: Fix jumbo frames error handling.
Date: Thu, 12 Feb 2009 16:55:33 -0800 (PST)
Message-ID: <20090212.165533.196988477.davem@davemloft.net>
References: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
	<1234396338-14859-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60663
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758053AbZBMAzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:55:39 -0500
In-Reply-To: <1234396338-14859-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Feb 2009 15:52:17 -0800

> If errors are reported on a frame descriptor, we need to
> account for the buffer pages that may have been used for this
> error packet and recycle them.  Otherwise, we may get the wrong
> pages for the next packet.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied.
