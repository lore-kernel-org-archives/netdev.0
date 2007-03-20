From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][SCTP]: Clean up stale data during association
 restart
Date: Mon, 19 Mar 2007 17:02:47 -0700 (PDT)
Message-ID: <20070319.170247.21591537.davem@davemloft.net>
References: <1174329483.3187.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030772AbXCTACs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 20:02:48 -0400
In-Reply-To: <1174329483.3187.11.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 19 Mar 2007 11:38:02 -0700

> [SCTP]: Clean up stale data during association restart
> 
> During association restart we may have stale data sitting
> on the ULP queue waiting for ordering or reassembly.  This
> data may cause severe problems if not cleaned up.  In particular
> stale data pending ordering may cause problems with receive
> window exhaustion if our peer has decided to restart the
> association.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
