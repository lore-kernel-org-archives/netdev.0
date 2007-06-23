From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 14:31:52 -0600
Message-ID: <m1r6o28laf.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <m1bqf6a8rd.fsf@ebiederm.dsl.xmission.com>
	<467D8056.1000307@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35377 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbXFWUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 16:37:57 -0400
In-Reply-To: <467D8056.1000307@gmx.net> (Carl-Daniel Hailfinger's message of
	"Sat, 23 Jun 2007 22:19:34 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net> writes:

> Can one namespace DoS other namespaces' access to the routing cache?
> Two scenarios come to mind:
> * provoking hash collisions
> * lock contention (sorry, haven't checked whether/how we do locking)

My initial expectation is that the protections we have to prevent one user from
performing a DoS on another user generally cover the cases between namespaces as
well.

Further in general global caches and global resource management is more efficient
then per namespace management.

Eric
