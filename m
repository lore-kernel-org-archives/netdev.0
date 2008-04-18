From: David Miller <davem@davemloft.net>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Thu, 17 Apr 2008 23:20:47 -0700 (PDT)
Message-ID: <20080417.232047.27944044.davem@davemloft.net>
References: <20080415.203108.55491723.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tonyb@cybernetics.com, mcarlson@broadcom.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753372AbYDRGUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:20:47 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABC73@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 16 Apr 2008 08:40:25 -0700

> Isn't it better to test for skb->data?  That's where we tell
> the hardware to start transmitting.

That's correct.
