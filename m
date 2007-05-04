From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [SCTP] Set assoc_id correctly during INIT
 collision.
Date: Fri, 04 May 2007 13:35:39 -0700 (PDT)
Message-ID: <20070504.133539.68042018.davem@davemloft.net>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
	<11783101753220-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35126
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S376143AbXEDUfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:35:38 -0400
In-Reply-To: <11783101753220-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 May 2007 16:22:54 -0400

> During the INIT/COOKIE-ACK collision cases, it's possible to get
> into a situation where the association id is not yet set at the time
> of the user event generation.  As a result, user events have an
> association id set to 0 which will confuse applications.
> 
> This happens if we hit case B of duplicate cookie processing.
> In the particular example found and provided by Oscar Isaula
> <Oscar.Isaula@motorola.com>, flow looks like this:
> A				B
> ---- INIT------->  (lost)
> 	    <---------INIT------
> ---- INIT-ACK--->
> 	    <------ Cookie ECHO
> ---

I suspect this changelog message was truncated because the
sign offs are not here, could you regenerate this?

Thanks.
