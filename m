From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 15:25:53 -0400 (EDT)
Message-ID: <20130408.152553.2156347442514600818.davem@davemloft.net>
References: <20130408154519.18177.57709.stgit@localhost>
	<20130408.121434.1965501143066047212.davem@davemloft.net>
	<3541094.5siDbVn1lC@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mvadkert@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761523Ab3DHTZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 15:25:55 -0400
In-Reply-To: <3541094.5siDbVn1lC@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 13:22:50 -0400

> Contrary to popular belief, my goal is to not destroy the scalability and/or 
> performance of our network stack, I just want to make sure we have a quality 
> network stack that is not only fast and scalable, but also preserves the 
> security functionality that makes Linux attractive to a number of users.

Get the violin out.

> To that end, we could put a #ifdef in the middle of
> tcp_make_synack(), but that seems very ugly to me and I think sets a
> bad precedence for the network stack and kernel as a whole.

Not an ifdef, a run time state test.
