From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Sat, 5 Feb 2011 14:57:10 +0100
Message-ID: <20110205135710.GA4752@gerrit.erg.abdn.ac.uk>
References: <20110202.170750.229739784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64816 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751564Ab1BEN53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Feb 2011 08:57:29 -0500
Content-Disposition: inline
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| I've left the DCCP code to keep using RFC3390 logic, if they
| wish to adopt this change in their code they can do so by
| simply deleting the rfc33390_bytes_to_packets() function and
| using TCP_INIT_CWND in their assignment.
| 
|  include/net/tcp.h      |   12 +++---------
|  net/dccp/ccids/ccid2.c |    9 +++++++++
Thank you for keeping the compatility, this seems an excellent way forward.

The change only affects CCID-2, TCP-like congestion control. This still has
some unresolved issues (related to cwnd) in its implementation.

Once these have been resolved, we can return to tracking the state of the 
art in TCP, for the moment your patch works best.
