From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] infiniband: use %p6 for printing message ids
Date: Tue, 28 Oct 2008 16:07:10 -0700
Message-ID: <ada8ws8mi8x.fsf@cisco.com>
References: <1225229901.11483.58.camel@brick>
	<1225234963.5269.228.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:32065 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbYJ1XHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:07:11 -0400
In-Reply-To: <1225234963.5269.228.camel@localhost> (Joe Perches's message of
	"Tue, 28 Oct 2008 16:02:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > I'm not sure any of these should be converted like this.
 > Infiniband gids are not IPv6 addresses.

Actually, they are.  The IB specification section 4.1 says:

 "A GID is a valid 128-bit IPv6 address (per RFC 2373) with additional
  properties / restrictions defined...."

and it makes sense to format an IB GID as an IPv6 address for display
(that's what the IB spec does; eg it mentions the "Multicast GID
FF02:0:0:0:0:0:0:1").

 - R.
