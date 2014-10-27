From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] sctp: add transport state in /proc/net/sctp/remaddr
Date: Mon, 27 Oct 2014 18:55:45 -0400 (EDT)
Message-ID: <20141027.185545.551457974536550723.davem@davemloft.net>
References: <1414093721-14921-1-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org, dborkman@redhat.com
To: michele@acksyn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbaJ0Wzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 18:55:47 -0400
In-Reply-To: <1414093721-14921-1-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Baldessari <michele@acksyn.org>
Date: Thu, 23 Oct 2014 21:48:40 +0200

> It is often quite helpful to be able to know the state of a transport
> outside of the application itself (for troubleshooting purposes or for
> monitoring purposes). Add it under /proc/net/sctp/remaddr.
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>

You can't change the layout of procfs files, applications parse
these files and any modification can potentially break such tools.

Secondly, even if this change were acceptable, targetting this
change at anything other than the net-next tree is not appropriate
because it is a new feature.
