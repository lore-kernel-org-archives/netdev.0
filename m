From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/7] net-timestamp: MSG_TSTAMP one-shot tx
 timestamps
Date: Wed, 25 Jun 2014 07:01:58 +0200
Message-ID: <20140625050158.GD3845@localhost.localdomain>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:46389 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaFYFCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 01:02:22 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so1322031wes.24
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 22:02:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403624632-17327-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 11:43:47AM -0400, Willem de Bruijn wrote:
> The kernel support datagram tx timestamping through socket option
> SO_TIMESTAMPING. This patch add send() flag MSG_TSTAMP to allow
> selectively requesting a timestamp for a single packet.

This is a nice idea. I wonder whether the drivers will react
correctly, need to think about it.

> MSG_TSTAMP does not depend on SO_TIMESTAMPING. Enabling both
> concurrently is redundant, but safe.
> 
> This patch adds support for IPv4 and IPv6 UDP sendmsg().

What about raw?

Thanks,
Richard
