From: David Miller <davem@davemloft.net>
Subject: Re: net: mark read-only arrays as const
Date: Wed, 05 Aug 2009 10:43:12 -0700 (PDT)
Message-ID: <20090805.104312.04332341.davem@davemloft.net>
References: <alpine.LSU.2.00.0908051708340.11618@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251AbZHERnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 13:43:03 -0400
In-Reply-To: <alpine.LSU.2.00.0908051708340.11618@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Wed, 5 Aug 2009 17:10:36 +0200 (CEST)

> net: mark read-only arrays as const
> 
> String literals are constant, and usually, we can also tag the array
> of pointers const too, moving it to the .rodata section.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Looks good, applied.
