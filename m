From: David Miller <davem@davemloft.net>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 02 Mar 2007 13:38:39 -0800 (PST)
Message-ID: <20070302.133839.17868570.davem@davemloft.net>
References: <200703021521.58821.alexandre.sidorenko@hp.com>
	<20070302.123325.28790131.davem@davemloft.net>
	<45E89437.3000902@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751052AbXCBVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 16:38:40 -0500
In-Reply-To: <45E89437.3000902@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Fri, 02 Mar 2007 16:16:39 -0500

> Please don't apply the patch I sent.  I've been thinking about this a 
> bit harder, and it may not fix this particular problem.  (Hard to say 
> without knowing exactly what it is.)  As the comment above 
> __tcp_select_window() states, we do not do full receive-side SWS 
> avoidance because of header prediction.
> 
> Alex, you're right I missed that special zero-window case.  I'm still 
> not quite sure I'm completely happy with this patch.  I'd like to think 
> about this a little bit harder...

Ok
