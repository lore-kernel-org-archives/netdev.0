From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 12:25:27 -0700
Message-ID: <20061020122527.56292b56@dxpl.pdx.osdl.net>
References: <20061019171814.281988608@osdl.org>
	<20061020.001530.35664340.davem@davemloft.net>
	<20061020081857.743b5eb7@localhost.localdomain>
	<20061020.122427.55507415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52679 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992709AbWJTTZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 15:25:33 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061020.122427.55507415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 12:24:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 20 Oct 2006 08:18:57 -0700
> 
> > Netdump is not in the tree, so I can't fix it. Also netdump is pretty
> > much superseded by kdump.
> 
> Unless kdump is %100 ready you can be sure vendors will ship netdump
> for a little while longer.  I think gratuitously breaking netdump is
> not the best idea.
> 
> It's not like netdump is some binary blob you can't get the source
> to easily. :-)
> 

Sorry, but why should we treat out-of-tree vendor code any differently
than out-of-tree other code.
