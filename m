From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][NETLABEL]: Move some initialization code into
 __init section.
Date: Sun, 17 Feb 2008 22:34:16 -0800 (PST)
Message-ID: <20080217.223416.220789561.davem@davemloft.net>
References: <47B2D086.8040008@openvz.org>
	<200802130837.17249.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752495AbYBRGdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 01:33:39 -0500
In-Reply-To: <200802130837.17249.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 13 Feb 2008 08:37:16 -0500

> On Wednesday 13 February 2008 6:12:06 am Pavel Emelyanov wrote:
> > Everything that is called from netlbl_init() can be marked with
> > __init. This moves 620 bytes from .text section to .text.init one.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> I ran into problems with __init and __exit once because I didn't fully 
> understand their impact; this caused me to be rather hesitant to make use of 
> them.  However, you seem to know what you are doing and these look like 
> reasonable changes to me so I'll ack this patch and if we do run into a 
> problem the fix should be pretty trivial.

Yes, this stuff can be non-trivial at best on some days :-)

> I appreciate you taking the time to find these optimizations, thanks again.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied.
