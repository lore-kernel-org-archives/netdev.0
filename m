From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 00/14] Always build GSO/GRO functionality into the
 kernel
Date: Thu, 15 Nov 2012 17:42:05 -0500 (EST)
Message-ID: <20121115.174205.2002769827912724231.davem@davemloft.net>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab2KOWmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 17:42:07 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All applied to net-next, but there were some minor conflicts (an
IS_ENABLED() conversion happened in ip6_output.c in net-next but the
context in your patch didn't have it) and git warnings (trailing
whitespace in the final patch).

I fixed them all up, but this is something you can easily take care
of yourself in the future.

Thanks.
