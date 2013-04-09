From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 09 Apr 2013 00:41:44 -0400 (EDT)
Message-ID: <20130409.004144.1226810973846202358.davem@davemloft.net>
References: <6182509.cOVcY8B4g7@sifl>
	<1365479891.3887.99.camel@edumazet-glaptop>
	<5163992F.30406@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pmoore@redhat.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org
To: casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab3DIEls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 00:41:48 -0400
In-Reply-To: <5163992F.30406@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It makes sure SYN/ACKs have a socket context attached to the
packet, which only LSMs actually need.

You participated in the thread where this stuff was discussed and the
initial version of this patch was posted, so this patch, or any aspect
of it, should not be a mystery.
