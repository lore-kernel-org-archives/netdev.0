From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 11 Jul 2006 23:11:49 -0700 (PDT)
Message-ID: <20060711.231149.77849003.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC093F9C0@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57747
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932443AbWGLGLC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 02:11:02 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093F9C0@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 11 Jul 2006 21:53:42 -0700

> There is no reason to find out if ECN is enabled or not for any
> TCP connections.  Hw just needs to watch the above bits in the
> incoming packets.

Correct, it can be done in a completely stateless manner.
