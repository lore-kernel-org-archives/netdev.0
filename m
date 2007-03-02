From: David Miller <davem@davemloft.net>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 02 Mar 2007 12:33:25 -0800 (PST)
Message-ID: <20070302.123325.28790131.davem@davemloft.net>
References: <200703021128.29208.alexandre.sidorenko@hp.com>
	<20070302.112542.18305896.davem@davemloft.net>
	<200703021521.58821.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965578AbXCBUd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 15:33:26 -0500
In-Reply-To: <200703021521.58821.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Fri, 2 Mar 2007 15:21:58 -0500

> they told us that they use small rcvbuf to throttle bandwidth for this 
> application. I explained it would be better to use TC for this purpose. They 
> agreed and will probably redesign their application in the future, but they 
> cannot do it right now. For the same reason they have to use the old 2.4.20 
> for a while - in big companies the important production software cannot be 
> changed quickly. 
> 
> The fix I suggested is trivial and should have no impact the case of 
> rcvfbuf>mtu, so I think it makes sense to include it in upstream kernel.

I have no objection to the fix, especially John's version.

I was just curious about the app, thanks for the info :)
