From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] EtherIP tunnel driver (RFC 3378)
Date: Thu, 14 Sep 2006 10:33:32 +0900
Message-ID: <20060914103332.641e7ff0@localhost.localdomain>
References: <20060911204129.GA28929@zlug.org>
	<4508AE92.1090202@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joerg Roedel <joro-lkml@zlug.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6334 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751308AbWINBdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 21:33:43 -0400
To: Philip Craig <philipc@snapgear.com>
In-Reply-To: <4508AE92.1090202@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 11:21:22 +1000
Philip Craig <philipc@snapgear.com> wrote:

> Joerg Roedel wrote:
> > +	 To configure tunnels an extra tool is required. You can download
> > +	 it from http://zlug.fh-zwickau.de/~joro/projects/ under the
> > +	 EtherIP section. If unsure, say N.
> 
> To obtain a list of tunnels, this tool calls SIOCGETTUNNEL
> (SIOCDEVPRIVATE + 0) for every device in /proc/net/dev. I don't think
> this is safe, but I don't have a solution for you.
> 
> Is there a reason why you have a separate tool rather than modifying
> iproute2?
> 
> I don't know if you are aware of this older etherip patch by Lennert
> Buytenhek: http://www.wantstofly.org/~buytenh/etherip/

SIOCDEVPRIVATE usage makes it hard to do 32 bit compatibility layer.
