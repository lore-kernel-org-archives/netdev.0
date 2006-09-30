From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 17:16:59 -0700
Message-ID: <adairj6yzr8.fsf@cisco.com>
References: <1159564053.3741.19.camel@rh4> <451D9007.6010905@garzik.org>
	<1159565963.3741.23.camel@rh4>
	<20060929.154917.125894679.davem@davemloft.net>
	<451DA57F.60609@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:787 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1422869AbWI3ARC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:17:02 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <451DA57F.60609@garzik.org> (Jeff Garzik's message of "Fri, 29 Sep 2006 19:00:15 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Jeff> The patch and description provided no information about
    Jeff> whether or not it would be better to blacklist 8132
    Jeff> globally, as we have already done with the 8131.

8131 and 8132 are quite different: AMD 8131 simply did not implement
MSI at all, so any attempt to use MSI by a device below such a bridge
has no chance at working.  8132 at least tried to implement MSI and
I know at least some devices work with it.

It may be that the 8132 MSI implementation is too buggy to be used in
practice, but that doesn't seem to be AMD's opinion.

 - R.
