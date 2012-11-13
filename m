From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC net-next] tun: implement BQL
Date: Tue, 13 Nov 2012 14:39:47 -0800
Message-ID: <20121113143947.35278b84@nehalam.linuxnetplumber.net>
References: <20121112132241.12bb94e4@nehalam.linuxnetplumber.net>
	<20121113.171939.1673751173342429141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44273 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754220Ab2KMWkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 17:40:49 -0500
In-Reply-To: <20121113.171939.1673751173342429141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 17:19:39 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 12 Nov 2012 13:22:41 -0800
> 
> > Add multiqueue BQL to tap device. Tested with VPN, doesn't have a big impact,
> > most likely because there is little queueing occuring at TAP device except
> > under case of forwarding.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> I think unless we can show it making an impact in a normal
> usage scenerio, we should leave it alone for now.

Agreed, that is why I submitted as RFC.
