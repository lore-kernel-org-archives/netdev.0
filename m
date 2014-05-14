From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}:
 Multiple transmit and receive queues
Date: Wed, 14 May 2014 22:24:32 +0100
Message-ID: <20140514212432.GA30413@zion.uk.xensource.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
 <526369072.20140514160923@eikelenboom.it>
 <20140514141347.GR6332@zion.uk.xensource.com>
 <53739757.5060905@citrix.com>
 <1296806729.20140514203719@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Bennieston <andrew.bennieston@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30596 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbaENVYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 17:24:35 -0400
Content-Disposition: inline
In-Reply-To: <1296806729.20140514203719@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 08:37:19PM +0200, Sander Eikelenboom wrote:
[...]
> 
> Got the patches from the thread .. but as i expected they interfere with 
> Zoltan's v3 fix for 3.15.
> 

This series targets net-next tree while Zoltan's fix targets net tree,
but I can see the possibility they clash with each other.

In any case the fix in this series for the bug you found is orthogonal
to Zoltan's fix, as I understand it that bug was in the setup / teardown
path, so you can at the very least verify this series doesn't have
that bug anymore.

Wei.

> > - Andrew
> >>
> >>> --
> >>> Sander
> >>>
> >>>> --
> >>>> Andrew J. Bennieston
> >>>
> >>>
> 
> 
