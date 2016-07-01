From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: Use symmetric hash for PACKET_FANOUT_HASH.
Date: Fri, 01 Jul 2016 17:07:01 -0400 (EDT)
Message-ID: <20160701.170701.1456256736115514983.davem@davemloft.net>
References: <20160701.160854.278188334806254498.davem@davemloft.net>
	<CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric@regit.org, victor@inliniac.net
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcGAVIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 17:08:20 -0400
In-Reply-To: <CALx6S34B33PUMfk4R662_WEjiafjheNbH=wH9r=QhYTK14nmqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 1 Jul 2016 13:52:58 -0700

> Why are symmetric hashes required?

Because they want load balancing, such that one flow only can overrun
one single socket not all of the ones in the fanout.

Every single user of AF_PACKET fanout wants this behavior.
