From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the
 permisions of netlink messages
Date: Wed, 07 May 2014 18:52:56 -0400 (EDT)
Message-ID: <20140507.185256.496391962242529591.davem@davemloft.net>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge@dti2.net, ebiederm@xmission.com, vgoyal@redhat.com,
	ssorce@redhat.com, security@kernel.org, netdev@vger.kernel.org,
	serge@hallyn.com
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbaEGWw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 18:52:58 -0400
In-Reply-To: <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 7 May 2014 15:26:11 -0700

> So what do we do?  Check permissions on connect and then use the
> cached result for send on a connected socket?  Check permitted caps
> instead of effective caps?

It should create the socket after changing perms.
