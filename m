From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 21:15:07 -0600
Message-ID: <m1przl9g78.fsf@ebiederm.dsl.xmission.com>
References: <m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
	<20071011082845.GA16527@gondor.apana.org.au>
	<m1tzoxehlo.fsf@ebiederm.dsl.xmission.com>
	<20071011.173046.66166737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34469 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757548AbXJLDQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 23:16:22 -0400
In-Reply-To: <20071011.173046.66166737.davem@davemloft.net> (David Miller's
	message of "Thu, 11 Oct 2007 17:30:46 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David, all.  My apologies. I'm tired and I don't have the energy to
grok yet another part of the kernel right now.  So I can not
productively participate in this discussion.

I do agree that the locking below dev_unicast_add() that was exposed
by the macvlan driver is unmaintainable even if it is currently
correct.

I don't see any fundamental problems with adding a might_sleep(),
ASSERT_RTNL.

I just don't have the energy to audit everything I feel I would have
to audit to be comfortable taking responsibility for adding the
might_sleep() or fixing the locking in dev_unicast_add() (which seems
more important).

So again my apologies.  This is all beyond what I can deal with at the moment.

Eric
