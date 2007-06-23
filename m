From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Resend] TIPC: Fix infinite loop in netlink handler
Date: Sat, 23 Jun 2007 14:08:27 -0700 (PDT)
Message-ID: <20070623.140827.91775363.davem@davemloft.net>
References: <20070623182546.GA26081@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: fw-kernel@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751489AbXFWVIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 17:08:09 -0400
In-Reply-To: <20070623182546.GA26081@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw-kernel@strlen.de>
Date: Sat, 23 Jun 2007 20:25:46 +0200

> From: Florian Westphal <fw@strlen.de>
> 
> The tipc netlink config handler uses the nlmsg_pid from the
> request header as destination for its reply. If the application
> initialized nlmsg_pid to 0, the reply is looped back to the kernel,
> causing hangup. Fix: use nlmsg_pid of the skb that triggered the
> request.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

I have this patch already, I'm just backlogged :-)

Please be patient.
