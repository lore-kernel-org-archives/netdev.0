From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: iphase: Fix set-but-not-used warnings.
Date: Tue, 12 Apr 2011 16:11:30 -0700 (PDT)
Message-ID: <20110412.161130.02277739.davem@davemloft.net>
References: <20110412.161047.233699167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756324Ab1DLXMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:12:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1036D30001
	for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 16:11:31 -0700 (PDT)
In-Reply-To: <20110412.161047.233699167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 12 Apr 2011 16:10:47 -0700 (PDT)

> 
> The "iavcc" case is obvious.
> 
> The intr_status and frmr_intr cases are reading a register to clear
> the chip status.  This driver is pretty old and creaky, and uses
> volatile pointer dereferences to do register I/O when it should be
> using readl() and friends.  However that it outside of the scope of
> these changes.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Hmmm, I missed a few more cases, updated patch coming up.
