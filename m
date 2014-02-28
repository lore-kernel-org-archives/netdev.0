From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: don't disable VLAN tag stripping in promisc
 mode
Date: Fri, 28 Feb 2014 12:55:37 -0500 (EST)
Message-ID: <20140228.125537.2031092349201090740.davem@davemloft.net>
References: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
	<20140227.172403.1870812305847598692.davem@davemloft.net>
	<20140228063142.GA2823@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, netdev@vger.kernel.org, rmody@brocade.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbaB1Rzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 12:55:42 -0500
In-Reply-To: <20140228063142.GA2823@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 28 Feb 2014 07:31:42 +0100

> Dave, do you think that enabling/disabling of vlan stripping should
> depend on promisc on/off? That seems very odd to me...

Absolutely, when you're in promisc mode you really want to see the
full raw frames, VLAN headers and all.
