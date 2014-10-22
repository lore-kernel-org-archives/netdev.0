From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH v2 net-next] net: ipv6: Add a sysctl to make
 optimistic addresses useful candidates
Date: Wed, 22 Oct 2014 14:13:42 +0200
Message-ID: <1413980022.2337.60.camel@localhost>
References: <1413864306-20055-1-git-send-email-ek@google.com>
	 <1413920743.32553.45.camel@localhost>
	 <CAAedzxpsaEGt+oO0xJWLxcjapdRYauHP4rAsKkf_skcdzbGEmg@mail.gmail.com>
	 <1413972774.2337.37.camel@localhost>
	 <CAAedzxpG1TEVVm_kHgRJcOO7qkFmyyYnfPL0ONN7GcypmtRq1g@mail.gmail.com>
	 <1413977771.2337.50.camel@localhost>
	 <CAKD1Yr08muZ0Dwwt5Xmi+mEFP9OBBYe9CceswsEzpm5PkMUCMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Kline <ek@google.com>, netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:34553 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933052AbaJVMNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 08:13:45 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id B3C00206C1
	for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 08:13:44 -0400 (EDT)
In-Reply-To: <CAKD1Yr08muZ0Dwwt5Xmi+mEFP9OBBYe9CceswsEzpm5PkMUCMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-10-22 at 20:50 +0900, Lorenzo Colitti wrote:
> On Wed, Oct 22, 2014 at 8:36 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > In the near future we also must introduce specific DAD events needed for
> > RFC7217 addresses (to count DAD progress and safe the information per
> > prefix in user space). I would prefer to keep the logic for RTM_NEWADDR
> > that the kernel will definitely allow the use of the address but
> > RTM_NEWADDR should be handled idempotent by user space.
> 
> Duplicate RTM_NEWADDR notifications aren't a problem though, right?
> The current code send RTM_NEWADDR every time an RA increases the
> lifetime of an address, so I think it's reasonable to assume that apps
> have to be able to deal with it, because it's pretty frequent.

I don't think it is a serious problem (or a problem at all). I would
just try to reduce the number of notifications, that's all.

Bye,
Hannes
