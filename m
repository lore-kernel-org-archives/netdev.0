From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: IP_MULTICAST_IF setsockopt now
 recognizes struct mreq
Date: Mon, 07 May 2012 23:03:46 -0400 (EDT)
Message-ID: <20120507.230346.1913300136495718066.davem@davemloft.net>
References: <1336120665-954-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758045Ab2EHDGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 23:06:24 -0400
In-Reply-To: <1336120665-954-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri,  4 May 2012 10:37:45 +0200

> Until now, struct mreq has not been recognized and it was worked with
> as with struct in_addr. That means imr_multiaddr was copied to
> imr_address. So do recognize struct mreq here and copy that correctly.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Fair enough, applied.
