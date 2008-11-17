From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] dccp: Feature negotiation for
 minimum-checksum-coverage
Date: Sun, 16 Nov 2008 22:53:56 -0800 (PST)
Message-ID: <20081116.225356.220374266.davem@davemloft.net>
References: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753135AbYKQGx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:53:56 -0500
In-Reply-To: <1226751079-15019-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:17 +0100

> This provides feature negotiation for server minimum checksum coverage
> which so far has been missing.
> 
> Since sender/receiver coverage values range only from 0...15, their
> type has also been reduced in size from u16 to u4.
> 
> Feature-negotiation options are now generated for both sender and receiver
> coverage, i.e. when the peer has `forgotten' to enable partial coverage
> then feature negotiation will automatically enable (negotiate) the partial
> coverage value for this connection.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
