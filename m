From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][SCTP]: Reset some transport and association
 variables on restart
Date: Mon, 19 Mar 2007 17:03:03 -0700 (PDT)
Message-ID: <20070319.170303.106263061.davem@davemloft.net>
References: <1174329486.3187.12.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030773AbXCTADD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 20:03:03 -0400
In-Reply-To: <1174329486.3187.12.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 19 Mar 2007 11:38:05 -0700

> [SCTP]: Reset some transport and association variables on restart
> 
> If the association has been restarted, we need to reset the
> transport congestion variables as well as accumulated error
> counts and CACC variables.  If we do not, the association
> will use the wrong values and may terminate prematurely.
> 
> This was found with a scenario where the peer restarted
> the association when lksctp was in the last HB timeout for
> its association.  The restart happened, but the error counts
> have not been reset and when the timeout occurred, a newly
> restarted association was terminated due to excessive
> retransmits.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
