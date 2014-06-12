From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2
 < v3.9.0
Date: Thu, 12 Jun 2014 10:47:35 -0700 (PDT)
Message-ID: <20140612.104735.11248268473559858.davem@davemloft.net>
References: <538DBDB3.7030505@redhat.com>
	<5399B575.7070604@redhat.com>
	<CA+55aFxQMw0s1N2SspU-DWbZ-h4mho4dVFrX5qm=ZHKrsUGbmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, alexander.h.duyck@intel.com,
	michael.riesch@omicron.at
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaFLRrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 13:47:37 -0400
In-Reply-To: <CA+55aFxQMw0s1N2SspU-DWbZ-h4mho4dVFrX5qm=ZHKrsUGbmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jun 2014 10:44:49 -0700

> David, I have to agree with Michal. If the user-space tool did what it
> had to do for old kernels, then new kernels should support the old
> semantics.
> 
> You can't call it a "bug" - user space does what it does and it was
> tested and worked.
> 
> And sure, it might have been a bug/misfeature of the old kernel, but
> we have to live with what we have done, not blame others. Once user
> space starts depending on our bugs, it's *our* problem.
> 
> Saying "fix your sh*t" is wrong, when we caused it to begin with.

Yeah I guess you're right and I'll end up applying Michal's patch.
