From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 06 Sep 2007 07:34:23 -0700 (PDT)
Message-ID: <20070906.073423.74747465.davem@davemloft.net>
References: <1189022828.4960.2.camel@dell>
	<20070906.040235.71121480.davem@davemloft.net>
	<20070906134508.GA10317@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:46053
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753539AbXIFOe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 10:34:26 -0400
In-Reply-To: <20070906134508.GA10317@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Thu, 6 Sep 2007 09:45:16 -0400

> Is is really necessary to get rid of the HT1000 patch?

Yes, absolutely and without a single doubt.

> commit e3008dedff4bdc96a5f67224cd3d8d12237082a0
> Author: Andy Gospodarek <andy@greyhouse.net>
> Date:   Thu May 10 22:58:57 2007 -0700
> 
>     PCI: disable MSI by default on systems with Serverworks HT1000 chips
> 
> This patch was designed to address tg3 and bnx2 messages printed on
> systems with HT1000 chips IIRC.  Are we going back to those messages on
> bnx2 or is there a workaround in that driver needed too?

Every report of that problem is with tg3 chips afflicted by this
INTX bug which is now worked around properly.

Even my Niagara T1000 box was hit by this absolutely stupid and
wrong MSI quirk, which is how I found this problem to begin with.

I'm reverting it.

