From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Tue, 25 Apr 2006 14:46:49 -0700 (PDT)
Message-ID: <20060425.144649.129407913.davem@davemloft.net>
References: <444D5E73.7020803@gmail.com>
	<20060425100149.636d6a1d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hzhong@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27823
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751324AbWDYVrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 17:47:52 -0400
To: shemminger@osdl.org
In-Reply-To: <20060425100149.636d6a1d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 25 Apr 2006 10:01:49 -0700

> >       # Hit    # miss Function:Filename@Line
> > !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
 ...
> How about just taking off the likely/unlikely in this case.

Why remove it when we'll now get a 50505 to 0 hit rate?
