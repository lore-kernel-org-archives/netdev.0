From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 21:04:01 -0700
Message-ID: <1193198641.11845.49.camel@localhost>
References: <471E2342.8090907@openvz.org>
	 <20071023.204350.59654390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3141 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbXJXEER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 00:04:17 -0400
In-Reply-To: <20071023.204350.59654390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-23 at 20:43 -0700, David Miller wrote:
> From: Pavel Emelyanov <xemul@openvz.org>
> Date: Tue, 23 Oct 2007 20:37:22 +0400
> > The /proc/net udp6, tcp6 and raw6 files print the IPs of
> > the connection ends. Make a NIP6Lxxx macros (L stands for
> > "long") for making the printing code look nicer.
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Applied, thanks.

Why aren't these addresses converted with ntohl?

