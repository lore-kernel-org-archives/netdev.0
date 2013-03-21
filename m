From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout on sparc64
Date: Thu, 21 Mar 2013 14:31:51 -0400 (EDT)
Message-ID: <20130321.143151.1903351543439987643.davem@davemloft.net>
References: <CA+FuTSewLdQZbWPLrdbtG2xtaWSdrPDO3yz6boXqgStYhh3fcg@mail.gmail.com>
	<1363889403-7712-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab3CUSb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 14:31:57 -0400
In-Reply-To: <1363889403-7712-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 21 Mar 2013 14:10:03 -0400

> The packetsocket fanout test uses a packet ring. Use TPACKET_V2
> instead of TPACKET_V1 to work around a known 32/64 bit issue in
> the older ring that manifests on sparc64.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
