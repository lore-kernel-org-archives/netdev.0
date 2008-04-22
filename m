From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 22 Apr 2008 15:05:59 -0700 (PDT)
Message-ID: <20080422.150559.115368150.davem@davemloft.net>
References: <m33apdyajf.fsf@maximus.localdomain>
	<480E5CB3.2080003@microgate.com>
	<480E4FA1.5020508@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulkf@microgate.com, khc@pm.waw.pl, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757086AbYDVWF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 18:05:57 -0400
In-Reply-To: <480E4FA1.5020508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 22 Apr 2008 16:50:41 -0400

> The fact that Krzysztof's solution was _small_ and _clean_ and easily 
> maintainable was the reason I merged it [into my tree].
> 
> IMO sometimes "one size fits all" is not the best solution.

This is besides the point.  We are discussing two things here:

1) How to "correctly" fix the syncppp private area bug.

2) How to, long term, support PPP properly in the kernel for
   various users.

The fact that non-HDLC users of syncppp got left broken is why I
objected to the change you merged in Jeff.  It simply duplicated the
majority of syncppp into the HDLC PPP code, which is just rediculious.

That had nothing to do with whether we should, in the long term, use
the generic PPP infrastructure we have now.

I would have been more than happy if syncppp was retained and fixed
properly, instead of being abandoned and duplicated in one fell swoop.
We don't do things like that Jeff.
