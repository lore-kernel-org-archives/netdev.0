From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: build failure from ip6mr stats change.
Date: Thu, 22 May 2008 12:32:00 +0400
Message-ID: <48352F80.6010708@openvz.org>
References: <20080521.144235.43063395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59966 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511AbYEVIeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 04:34:31 -0400
In-Reply-To: <20080521.144235.43063395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> How could you possibly have test compiled this?
> 
> You kept the "stats->foo" dereferences but those all
> need to be "stats.foo"

Yikes! 8( I swear I saw the

  CC    net/ipv6/ip6mr.o

line when building one...

Argh :( I didn't turn the CONFIG_IP_PIMSM on and all statistics
happened to be under this option only.

> I've fixed it up as below.
> 
> UGH, the ipv4 ipmr patch has the same problem, I'll fix that up to :-(

Thank you. Sorry for bad patchset :(

> ip6mr: Use on-device stats instead of private ones.
> 
> Similar to ipmr.
> 
> [ Fix build failures -DaveM ]
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: David S. Miller <davem@davemloft.net>
