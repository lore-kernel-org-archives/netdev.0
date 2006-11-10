From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] tcp: restrict congestion control choices
Date: Thu, 09 Nov 2006 16:35:31 -0800 (PST)
Message-ID: <20061109.163531.89126691.davem@davemloft.net>
References: <20061031230140.191929094@osdl.org>
	<20061031230213.880147861@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6532
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424312AbWKJAfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:35:37 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031230213.880147861@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 31 Oct 2006 15:01:43 -0800

> Allow normal users to only choose among a restricted set of congestion
> control choices.  The default is reno and what ever has been configured
> as default. But the policy can be changed by administrator at any time.
> 
> For example, to allow any choice:
>     cp /proc/sys/net/ipv4/tcp_available_congestion_control \
>        /proc/sys/net/ipv4/tcp_allowed_congestion_control
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks a lot Stephen.
