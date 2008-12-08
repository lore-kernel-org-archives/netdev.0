From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] dccp: Remove obsolete parts of the old CCID
 interface
Date: Mon, 08 Dec 2008 01:18:12 -0800 (PST)
Message-ID: <20081208.011812.02391476.davem@davemloft.net>
References: <1228581657-6724-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-5-git-send-email-gerrit@erg.abdn.ac.uk>
	<1228581657-6724-6-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751404AbYLHJSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:18:11 -0500
In-Reply-To: <1228581657-6724-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  6 Dec 2008 17:40:55 +0100

> The TX/RX CCIDs of the minisock are now redundant: similar to the Ack Vector
> case, their value equals initially that of the sysctl, but at the end of
> feature negotiation may be something different.
> 
> The old interface removed by this patch thus has been replaced by the newer
> interface to dynamically query the currently loaded CCIDs.
> 
> Also removed are the constructors for the TX CCID and the RX CCID, since the
> switch "rx <-> non-rx" is done by the handler in minisocks.c (and the handler
> is the only place in the code where CCIDs are loaded).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
