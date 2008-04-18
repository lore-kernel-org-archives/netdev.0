From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tg3: 5701 DMA corruption fix
Date: Fri, 18 Apr 2008 14:57:46 -0700 (PDT)
Message-ID: <20080418.145746.248076404.davem@davemloft.net>
References: <20080416222741.GA20272@localdomain>
	<20080417.232612.04456205.davem@davemloft.net>
	<1208540735.16633.102.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net,
	tonyb@cybernetics.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750985AbYDRV5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 17:57:45 -0400
In-Reply-To: <1208540735.16633.102.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 18 Apr 2008 10:45:35 -0700

> I think it is ok, because when we call pci_get_device() next time, we'll
> pass in the old bridge so that it can find the next one.  pci_get_device
> () will automatically decrement the reference count on the old bridge.

You're absolutely correct.

I still would appreciate the version bump being combined with
the bug fix patch, could someone please do that?

Thanks!
