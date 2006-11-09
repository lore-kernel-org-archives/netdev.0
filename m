From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3_close question
Date: Thu, 9 Nov 2006 08:35:36 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FCCE@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <5cac192f0611090544t18a28d0do943acacb8824df80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:25096 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S966041AbWKIQfx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 11:35:53 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5cac192f0611090544t18a28d0do943acacb8824df80@mail.gmail.com>
To: "Eric Lemoine" <eric.lemoine@gmail.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Lemoine wrote:

> Instead of tg3_netif_stop() tg3_close() uses netif_stop_queue() to
> stop xmit. This doesn't seem right to me. E.g. another CPU in tg3_tx()
> could do netif_wake_queue() just after tg3_close() did
> netif_stop_queue(). Isn't a bug?
> 

I think you're right.  It is more correct to call tg3_netif_stop().

