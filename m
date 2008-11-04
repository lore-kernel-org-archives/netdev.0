From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH]: net/: Kill now superfluous ->last_rx stores.
Date: Mon, 3 Nov 2008 22:37:49 -0800
Message-ID: <20081103223749.79ea5eb9@extreme>
References: <20081103.220145.73307270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35933 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147AbYKDGhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 01:37:55 -0500
In-Reply-To: <20081103.220145.73307270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Nov 2008 22:01:45 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> net/: Kill now superfluous ->last_rx stores.
> 
> The generic packet receive code takes care of setting
> netdev->last_rx when necessary, for the sake of the
> bonding ARP monitor.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Is there a way to get all of drivers/net/*.c with spdiff?
