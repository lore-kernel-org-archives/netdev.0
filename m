From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Tue, 30 Mar 2010 09:29:14 -0700
Message-ID: <20100330092914.4f3e9ed3@nehalam>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	<20100330161746.9628.40723.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33057 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755115Ab0C3R0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:26:50 -0400
In-Reply-To: <20100330161746.9628.40723.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 17:17:46 +0100
James Chapman <jchapman@katalix.com> wrote:

> When dumping L2TP PPP sessions using /proc/net/l2tp, get
> the assigned PPP device name from PPP using ppp_dev_name().
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>
> Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
>

Why is this a necessary API?
Why not put it in debugfs if just a debugging tool?
