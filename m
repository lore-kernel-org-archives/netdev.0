From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] infiniband: use %p6 for printing message ids
Date: Tue, 28 Oct 2008 15:00:48 -0700
Message-ID: <adahc6wmlbj.fsf@cisco.com>
References: <1225229901.11483.58.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:52444 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbYJ1WAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:00:50 -0400
In-Reply-To: <1225229901.11483.58.camel@brick> (Harvey Harrison's message of
	"Tue, 28 Oct 2008 14:38:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks fine (once the p6 support goes in of course).  You could also look
at IPOIB_GID_FMT in drivers/infiniband/ulp/ipoib for further things
worth converting.  And I didn't notice if you already did it, but
drivers/net/mlx4 has lots of similar stuff to convert the same way as
you did for mthca.

Thanks,
  Roland
