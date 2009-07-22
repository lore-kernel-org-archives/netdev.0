From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv4: IP_RECVERR should also enqueue source quench
 messages
Date: Tue, 21 Jul 2009 20:07:29 -0700 (PDT)
Message-ID: <20090721.200729.212201103.davem@davemloft.net>
References: <1248219127-3203-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58324
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756016AbZGVDHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 23:07:24 -0400
In-Reply-To: <1248219127-3203-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 22 Jul 2009 01:32:07 +0200

> Currently ICMP source quench messages are silently dropped and not
> enqueued in a per-socket error queue. The socket option IP_RECVERR
> enables a connected datagram socket to notice error conditions received
> via ICMP. This modification allows applications to notice ICMP source
> quench error condition too.
> 
> Side note: source quench are obsolete since day ~0 and are one of the
> early design mistakes of the Internet. Anyway, this does not interfere
> with the fact that a connected socket should not be informed about
> received source quench messages.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

I'm almost entirely sure that this behavior is intentional.

All RFCs say to ignore source quench messages with impunity, and Linux
interprets this to mean for our userland interfaces too.

I'm not applying this, sorry.
