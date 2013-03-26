From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5] set transport header for untrusted packets
Date: Tue, 26 Mar 2013 12:45:35 -0400 (EDT)
Message-ID: <20130326.124535.2213486098970156228.davem@davemloft.net>
References: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934186Ab3CZQpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:45:38 -0400
In-Reply-To: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 26 Mar 2013 14:19:54 +0800

> We don't set transport header for untrusted packets in the past, but for the
> follwoing reasons, we need to do it now.
> 
> - Better packet length estimation (introduced in 1def9238) needs l4 header for
>   gso packets to compute the header length.
> - Some driver needs l4 header (e.g. ixgbe needs tcp header to do atr).
> 
> So this patches tries to set transport header for packets from untrusted source
> (netback, packet, tuntap, macvtap). Plus a fix for better estimation on packet
> length for DODGY packet.
> 
> Tested on tun/macvtap/packet, compile test on netback.

Looks good to me, series applied, thanks Jason.
