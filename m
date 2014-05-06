From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Need to sock_put on csum error
Date: Mon, 05 May 2014 23:17:42 -0400 (EDT)
Message-ID: <20140505.231742.528804587564258755.davem@davemloft.net>
References: <alpine.DEB.2.02.1405051641510.11662@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933762AbaEFDRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:17:44 -0400
In-Reply-To: <alpine.DEB.2.02.1405051641510.11662@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 May 2014 16:43:58 -0700 (PDT)

> Commit 4068579e1e098fa81d48db9ba4432ab664c58561 ("net: Implmement
> RFC 6936 (zero RX csums for UDP/IPv6)") introduced zero checksums
> being allowed for IPv6, but in the case that a socket disallows a
> zero checksum on RX we need to sock_put.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied to net-next, thanks Tom.
