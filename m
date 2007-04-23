From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH 2/5 2.6.21-rc7] l2tp: pppol2tp changes to existing ppp kernel headers
Date: 23 Apr 2007 09:21:58 -0700
Message-ID: <20070423162158.9449.qmail@farnsworth.org>
References: <200704231601.l3NG13hW030163@quickie.katalix.com>
To: jchapman@katalix.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4506 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754016AbXDWQWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 12:22:00 -0400
In-Reply-To: <200704231601.l3NG13hW030163@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> [L2TP]: Modify kernel headers for L2TP.

Since the Subject: line becomes the first line of the commit comments,
the above line is redundant.

> This patch adds L2TP definitions to existing PPP and socket headers.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> ---
> 
> Add struct sockaddr_pppol2tp to carry L2TP-specific address
> information for the PPPoX (PPPoL2TP) socket. Unfortunately we can't
> use the union inside struct sockaddr_pppox because the L2TP-specific
> data is larger than the current size of the union and we must preserve
> the size of struct sockaddr_pppox for binary compatibility.
> 
> Also add an ioctl to allow userspace to obtain L2TP counters and state
> from the kernel.

In my opinion, the above info is sufficiently useful to be included
commit comments.

-Dale Farnsworth
