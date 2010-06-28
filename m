From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Mon, 28 Jun 2010 21:03:13 +0200
Message-ID: <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se> <20100611084854.0680c014@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:42903 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0F1TF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 15:05:26 -0400
In-Reply-To: <20100611084854.0680c014@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48:54:
>
> When Linux is used as a router, it is undesirable for the kernel to process
> incoming packets when the address assigned to the interface is down.
> The initial problem report was for a management application that used ICMP
> to check link availability.
>
> The default is disabled to maintain compatibility with previous behavior.
> This is not recommended for server systems because it makes fail over more
> difficult, and does not account for configurations where multiple interfaces
> have the same IP address.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Ping David et. all?
I too want this.

 Jocke

