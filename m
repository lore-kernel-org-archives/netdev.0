From: David Miller <davem@davemloft.net>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Tue, 05 Jan 2010 19:59:53 -0800 (PST)
Message-ID: <20100105.195953.16499086.davem@davemloft.net>
References: <20100105.163911.10233438.davem@davemloft.net>
	<20100106020756.GA4378@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755363Ab0AFD7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 22:59:48 -0500
In-Reply-To: <20100106020756.GA4378@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 5 Jan 2010 21:07:56 -0500

> Dave, If that patch fixes the problem (waiting on test results now,
> but I figure it will), what if we add a parameter to tcp_sequence
> (and tcp_validate_incomming), that represents an offset to trim from
> end_seq (so that we can effectively ignore the garbage byte)?

Sure, we could do that too, and it would be an improvement.

Let's first wait for test results and also give a bit for
others to potentially come up with implementation ideas.
