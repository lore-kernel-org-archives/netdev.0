From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "af-packet: Use existing netdev reference for
 bound sockets."
Date: Sun, 17 Nov 2013 21:28:12 -0500 (EST)
Message-ID: <20131117.212812.2002429039119385634.davem@davemloft.net>
References: <1384734522-36613-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, willemb@google.com, phil@nwl.cc,
	edumazet@google.com, netdev@vger.kernel.org
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab3KRC2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 21:28:17 -0500
In-Reply-To: <1384734522-36613-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Sun, 17 Nov 2013 16:28:42 -0800

> This reverts commit 827d978037d7d0bf0860481948c6d26ead10042f.
> 
> The patch introduced a race condition between packet_snd and packet_notifier
> when a net_device is being unregistered. In the case of a bound socket,
> packet_notifier can drop the last reference to the net_device and packet_snd
> might be sending a packet over a freed net_device.

You need to provide a proper "Signed-off-by: ", you need to refer to
commits not just buy SHA1 ID but also by the commit header text in
parenthesis and double quotes.
