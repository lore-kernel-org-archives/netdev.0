From: David Miller <davem@davemloft.net>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6 - bisected
 - twice
Date: Wed, 18 Mar 2009 18:39:30 -0700 (PDT)
Message-ID: <20090318.183930.35290998.davem@davemloft.net>
References: <49B581D3.6060807@krogh.cc>
	<20090313.161217.52045656.davem@davemloft.net>
	<8799.1236986836@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@redhat.com, aowi@novozymes.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751389AbZCSBjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:39:43 -0400
In-Reply-To: <8799.1236986836@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 13 Mar 2009 16:27:16 -0700

> David Miller <davem@davemloft.net> wrote:
> 
> >From: Jesper Krogh <jesper@krogh.cc>
> >Date: Mon, 09 Mar 2009 21:53:39 +0100
> >
> >> Jay Vosburgh wrote:
> >> > 	However, I did find another bug I introduced during the "mii
> >> > refactor" patch that you mentioned as being the original source of the
> >> > problem.  That bug will cause 802.3ad to not notice speed changes.
> >> > 	Could you test the patch below on your 2.6.68.7 and/or 2.6.27.19
> >> > and see if it resolves your problem (without the forcedeth patch)?
> >> 
> >> There was something missing from the header to make it compile.. I found that in a later version. Patch below fixed the problem (without the forcedeth patch).
> >
> >Jay please resend this with proper signoffs etc. if you want
> >me to apply it.
> 
> 	I posted it again with the usual stuff a day or two after I
> posted the test patch; I'll append it to the end of this email.  Note
> that the below patch has a minor cosmetic change from the test patch.
> 
> 	I believe this fix should go to -stable for 2.6.26 and 2.6.27,
> but it'll need the change Jesper added to pick up a macro that was added
> to mainline:

Applied and I'll queue it up for -stable too, thanks!
