From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] unix: Add /proc/net/unix_peers file
Date: Mon, 05 Dec 2011 18:47:16 -0500 (EST)
Message-ID: <20111205.184716.1110676872679899930.davem@davemloft.net>
References: <4ED7BC6E.3040600@parallels.com>
	<20111204.132510.1708510157080644595.davem@davemloft.net>
	<4EDC9C07.6070904@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932715Ab1LEXrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:47:21 -0500
In-Reply-To: <4EDC9C07.6070904@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 05 Dec 2011 14:25:11 +0400

> On 12/04/2011 10:25 PM, David Miller wrote:
>> Please extend the netlink socket dumping so that it works with
>> AF_UNIX sockets and subsequently added the necessary netlink
>> attribute to provide the peer value.
> 
> OK, will do it this way. AFAIU you're talking about the NETLINK_INET_DIAG, right?

Yes.

If that framework, for some reason, doesn't fit AF_UNIX sockets well
or needs to be genericized, please feel free to do whatever you think
is necessary to address that.

Thanks.
