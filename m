From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Tue, 25 Apr 2006 15:16:35 -0700
Message-ID: <20060425151635.549d3400@localhost.localdomain>
References: <444D5E73.7020803@gmail.com>
	<20060425100149.636d6a1d@localhost.localdomain>
	<20060425.144649.129407913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hzhong@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47513 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751577AbWDYWQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 18:16:53 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060425.144649.129407913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Apr 2006 14:46:49 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 25 Apr 2006 10:01:49 -0700
> 
> > >       # Hit    # miss Function:Filename@Line
> > > !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
>  ...
> > How about just taking off the likely/unlikely in this case.
> 
> Why remove it when we'll now get a 50505 to 0 hit rate?

Depends on the data stream, but I guess if we are seeing high loss
we really don't care about the CPU branch prediction.
