From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 17/16] net: Disable netfilter sockopts when not in the initial network namespace
Date: Wed, 12 Sep 2007 06:16:25 -0600
Message-ID: <m18x7ccc4m.fsf@ebiederm.dsl.xmission.com>
References: <m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
	<20070912.045903.104046208.davem@davemloft.net>
	<20070912.050311.78725619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:60195 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764287AbXILMR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:17:26 -0400
In-Reply-To: <20070912.050311.78725619.davem@davemloft.net> (David Miller's
	message of "Wed, 12 Sep 2007 05:03:11 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I added the following patch to net-2.6.24 to kill a warning
> since net_alloc() has no users (yet).

Reasonable, and thanks for merging these.

Having a solid place to start helps a lot.

I will see if I can get the /proc races fixed shortly.

Eric
