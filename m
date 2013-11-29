From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: Do not double-count received packets
Date: Fri, 29 Nov 2013 16:07:46 -0500 (EST)
Message-ID: <20131129.160746.1842192161038812093.davem@davemloft.net>
References: <1385487432-17651-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498Ab3K2VHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:07:48 -0500
In-Reply-To: <1385487432-17651-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 26 Nov 2013 12:37:12 -0500

> Currently macvlan will count received packets after calling each
> vlans receive handler.   Macvtap attempts to count the packet
> yet again when the user reads the packet from the tap socket.
> This code doesn't do this consistently either.  Remove the
> counting from macvap and let only macvlan count received
                ^^^^^^
--> macvtap

> packets.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, with the above typo fixed, thanks.
