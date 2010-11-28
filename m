From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 [Patch 1/1][BUG-FIX] dccp: advancing the Ack window
Date: Sun, 28 Nov 2010 11:29:48 -0800 (PST)
Message-ID: <20101128.112948.15234568.davem@davemloft.net>
References: <20101123123656.GB3915@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab0K1T3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:29:22 -0500
In-Reply-To: <20101123123656.GB3915@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Nov 2010 13:36:56 +0100

> dccp: fix error in updating the GAR
> 
> This fixes a bug in updating the Greatest Acknowledgment number Received (GAR): 
> the current implementation does not track the greatest received value -
> lower values in the range AWL..AWH (RFC 4340, 7.5.1) erase higher ones.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, thanks.
