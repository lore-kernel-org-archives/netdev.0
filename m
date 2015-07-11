From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: inet_diag: always export IPV6_V6ONLY sockopt
 for listening sockets
Date: Fri, 10 Jul 2015 23:25:48 -0700 (PDT)
Message-ID: <20150710.232548.357031018488272501.davem@davemloft.net>
References: <1436463030.24939.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<1436521197-912-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbbGKGZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:25:49 -0400
In-Reply-To: <1436521197-912-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Fri, 10 Jul 2015 11:39:57 +0200

> Reconsidering my commit 20462155 "net: inet_diag: export IPV6_V6ONLY
> sockopt", I am not happy with the limitations it causes for socket
> analysing code in userspace. Exporting the value only if it is set makes
> it hard for userspace to decide whether the option is not set or the
> kernel does not support exporting the option at all.
> 
> From an auditor's perspective, the interesting question for listening
> AF_INET6 sockets is: "Does it NOT have IPV6_V6ONLY set?" Because it is
> the unexpected case. This patch allows to answer this question reliably.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> Cc: Eric Dumazet <edumazet@google.com>

Applied, thanks.
