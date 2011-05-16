From: David Miller <davem@davemloft.net>
Subject: Re: Null pointer dereference in icmp_send
Date: Mon, 16 May 2011 17:22:58 -0400 (EDT)
Message-ID: <20110516.172258.454975314148851877.davem@davemloft.net>
References: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roberto.paleari@emaze.net
To: joystick@idea.sec.dico.unimi.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756054Ab1EPVXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:23:11 -0400
In-Reply-To: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aristide Fattori <joystick@idea.sec.dico.unimi.it>
Date: Mon, 16 May 2011 23:06:32 +0200

> in function icmp_send() (net/ipv4/icmp.c), the parameter passed to
> dev_net() function is not properly validated.

It doesn't need to be.

If 'rt' is not NULL, then rt->dst.dev is always not NULL and
therefore no checks are necessary.
