From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tg3: Avoid Send BD corruption
Date: Wed, 10 Sep 2008 22:46:18 -0700 (PDT)
Message-ID: <20080910.224618.113269063.davem@davemloft.net>
References: <20080911051244.GA27384@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYIKFqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 01:46:24 -0400
In-Reply-To: <20080911051244.GA27384@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 10 Sep 2008 22:12:45 -0700

> On 5761 and 5784 ASIC revision chips, there is a chance that send BDs
> can be corrupted when CLKREQ is enabled.  This patch turns CLKREQ off
> while the driver is in control of the device.
> 
> This patch also bumps up the version to 3.95.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Are users really hitting this or was this discovered by your own
internal testing and verification?
