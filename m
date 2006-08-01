From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: don't call upper-layer disconnect function if
 not connected
Date: Tue, 01 Aug 2006 15:07:53 -0700 (PDT)
Message-ID: <20060801.150753.78709843.davem@davemloft.net>
References: <44CFB026.7050907@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48345
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751209AbWHAWH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 18:07:57 -0400
To: brian.haley@hp.com
In-Reply-To: <44CFB026.7050907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 01 Aug 2006 15:48:54 -0400

> Calling connect() with AF_UNSPEC will disconnect a socket, but we don't 
> need to do any work if the socket isn't currently connected.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

The socket could have been bind()'d to, in which case it will
not move to connected state and we still need to invoke
the disconnect methods such as udp_disconnect() to clear out
that binding.

You seem to be groveling in random areas of the ipv4 and ipv6 stack,
what are you working on?
