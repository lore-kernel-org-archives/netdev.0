From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sctp: Add GSO support
Date: Tue, 03 May 2016 12:09:15 -0400 (EDT)
Message-ID: <20160503.120915.2184693151751282220.davem@davemloft.net>
References: <cover.1461965035.git.marcelo.leitner@gmail.com>
	<20160502.191614.608026435064266168.davem@davemloft.net>
	<20160503114918.GD5676@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, David.Laight@ACULAB.COM,
	alexander.duyck@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535AbcECQJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:09:19 -0400
In-Reply-To: <20160503114918.GD5676@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 3 May 2016 08:49:18 -0300

> So this is just for pure tx path, no forwarding involved.

And if that GSO segment is looped back into the stack via the
loopback interface, the packet classifier mirror action, or
netfilter?

You cannot just GSO things and then not handle such packets
properly on receive.
