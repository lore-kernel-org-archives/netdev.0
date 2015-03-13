From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Don't set s_addr in vxlan_create_sock
Date: Thu, 12 Mar 2015 23:24:02 -0400 (EDT)
Message-ID: <20150312.232402.1611238890043593143.davem@davemloft.net>
References: <1426212058-11224-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbCMDYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:24:04 -0400
In-Reply-To: <1426212058-11224-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 13 Mar 2015 11:00:58 +0900

> In the case of AF_INET s_addr was set to INADDR_ANY (0) which which both
> symmetric with the AF_INET6 case, where s_addr is not set, and unnecessary
> as udp_conf is zeroed out earlier in the same function.
> 
> I suspect this change does not have any run-time effect due to compiler
> optimisations. But it does make the code a little easier on the/my eyes.
> 
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Seems totally reasonable, applied, thanks Simon.
