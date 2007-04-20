From: David Miller <davem@davemloft.net>
Subject: Re: SIOCGIFCOUNT
Date: Fri, 20 Apr 2007 15:41:33 -0700 (PDT)
Message-ID: <20070420.154133.76947512.davem@davemloft.net>
References: <200704210004.51278.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754514AbXDTWla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 18:41:30 -0400
In-Reply-To: <200704210004.51278.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sat, 21 Apr 2007 00:04:51 +0200

> 0x8938 is SIOCGIFCOUNT. As far as I can see it is only defined in
> sockios.h, but not implemented?
>
> Should it be removed from the include file or implemented?

Unless we can be %100 certain not one build will break by removing it,
we should keep it around.

> I probably will add a dummy compat ioctl entry to shut the JDK up at least.

Yes, but please do this generically so that the warning gets
quieted on all compat platforms that might hit this.

Thanks.
