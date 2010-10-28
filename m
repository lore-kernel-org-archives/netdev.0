From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Thu, 28 Oct 2010 11:49:41 -0700 (PDT)
Message-ID: <20101028.114941.39177249.davem@davemloft.net>
References: <20101027.122757.98903207.davem@davemloft.net>
	<AANLkTikdh-kqroCDA5EsjSMTLjViqe_U=hxM1L6U4Ppb@mail.gmail.com>
	<4CC9C4B0.50404@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, jon.maloy@ericsson.com,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	security@kernel.org, allan.stephens@windriver.com,
	rds-devel@oss.oracle.com
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51581
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934045Ab0J1StS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:49:18 -0400
In-Reply-To: <4CC9C4B0.50404@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Thu, 28 Oct 2010 11:45:04 -0700

> Yes that's right, it's to map a memory region that will be the target
> of an RDMA operation. I don't know why struct rds_iovec was used
> instead of struct iovec, but I think we're stuck, since it's part of
> our socket API.
> 
> I'll send DaveM patches to fix those two immediately-identified
> problems today, and we'll take a good long look at the rest of the
> code for further issues.

FWIW, I would strongly suggest that you copy the iovecs into the
kernel before parsing them like sys_sendmsg() and sys_recvmsg() do in
net/socket.c as part of these fixes.
