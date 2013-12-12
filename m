From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] virtio_net: set multicast filter list to
 host
Date: Thu, 12 Dec 2013 13:26:17 -0500 (EST)
Message-ID: <20131212.132617.1255637880637039918.davem@davemloft.net>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab3LLS0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:26:19 -0500
In-Reply-To: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 9 Dec 2013 16:16:32 -0800

> The virtio_net driver never sends the multicast address list to
> the host. This is because send command takes a pointer to scatter list
> to send but only inserts that one entry into the outgoing scatter list.
> 
> This bug has been there since:
> commit f565a7c259d71cc186753653d978c646d2354b36
> Author: Alex Williamson <alex.williamson@hp.com>
> Date:   Wed Feb 4 09:02:45 2009 +0000
> 
>     virtio_net: Add a MAC filter table
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

I'm just going to assume for now that you agree with the anaylsis of
others that the sg lists are processed properly as-is, and therefore
your patch isn't necessary.

Let me know if that is not the case.

Thanks.
