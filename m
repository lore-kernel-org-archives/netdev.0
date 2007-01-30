From: David Miller <davem@davemloft.net>
Subject: Re: buggy IFB driver change
Date: Tue, 30 Jan 2007 14:21:56 -0800 (PST)
Message-ID: <20070130.142156.55506918.davem@davemloft.net>
References: <20070130.131246.71091370.davem@davemloft.net>
	<45BFBE1B.2040508@pobox.com>
	<Pine.LNX.4.64.0701301411170.3611@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, m.kozlowski@tuxland.pl,
	akpm@osdl.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751864AbXA3WV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 17:21:57 -0500
In-Reply-To: <Pine.LNX.4.64.0701301411170.3611@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Jan 2007 14:13:14 -0800 (PST)

> On Tue, 30 Jan 2007, Jeff Garzik wrote:
> > 
> > I'm about to crash, can you or Linus handle the correction?
> 
> Reverted, pushed out.
> 
> Davem, if you have any other issues, just push me any fixes. I'm going to 
> do a final -rc7 today (way too many changes for me to be happy releasing a 
> 2.6.20 without a new -rc after all), and hope for the final 2.6.20 by the 
> end of this week.
> 
> Sounds like a plan?

That works for me, I have 3 small netfilter fixes to review
(one is a nasty divide by zero case) and one potential TCP fix.
I'll take care of those right now and push.
