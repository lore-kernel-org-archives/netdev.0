From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: Fixup v4mapped behaviour to comply with Sock
 API
Date: Thu, 31 Jul 2014 21:49:37 -0700 (PDT)
Message-ID: <20140731.214937.293535080709472306.davem@davemloft.net>
References: <20140730184053.GA28087@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, dborkman@redhat.com,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	netdev@vger.kernel.org
To: jgunthorpe@obsidianresearch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaHAEtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 00:49:39 -0400
In-Reply-To: <20140730184053.GA28087@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Wed, 30 Jul 2014 12:40:53 -0600

> The SCTP socket extensions API document describes the v4mapping option as
> follows:
> 
> 8.1.15.  Set/Clear IPv4 Mapped Addresses (SCTP_I_WANT_MAPPED_V4_ADDR)
> 
>    This socket option is a Boolean flag which turns on or off the
>    mapping of IPv4 addresses.  If this option is turned on, then IPv4
>    addresses will be mapped to V6 representation.  If this option is
>    turned off, then no mapping will be done of V4 addresses and a user
>    will receive both PF_INET6 and PF_INET type addresses on the socket.
>    See [RFC3542] for more details on mapped V6 addresses.
> 
> This description isn't really in line with what the code does though.
 ...
> Tested bind, getpeername, getsockname, connect, and recvmsg for proper
> behaviour in v4mapped = 1 and 0 cases.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

This has been this way since pre-GIT times, so I'm applying this to net-next,
thanks.
