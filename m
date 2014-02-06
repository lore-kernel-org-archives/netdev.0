From: David Howells <dhowells@redhat.com>
Subject: Re: Should I use the pernet stuff for rxrpc sysctls
Date: Thu, 06 Feb 2014 23:12:10 +0000
Message-ID: <25420.1391728330@warthog.procyon.org.uk>
References: <25347.1391728096@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094AbaBFXMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Feb 2014 18:12:36 -0500
In-Reply-To: <25347.1391728096@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I also noticed this in net/core/sysctl_net_core.c:

	static struct ctl_table net_core_table[] = {
	#ifdef CONFIG_NET  <---
		{

But isn't the content of the net/core/ directory contingent on CONFIG_NET=y in
net/Makefile, rendering this redundant?

David
