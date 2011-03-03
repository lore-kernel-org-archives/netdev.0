From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] cnic: Prevent status block race conditions
 with hardware
Date: Wed, 02 Mar 2011 16:00:12 -0800 (PST)
Message-ID: <20110302.160012.35056753.davem@davemloft.net>
References: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756328Ab1CBX7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 18:59:35 -0500
In-Reply-To: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 2 Mar 2011 15:00:49 -0800

> The status block index is used to acknowledge interrupt events and must
> be read before checking for the interrupt events, so we need to add rmb()
> to guarantee that.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
