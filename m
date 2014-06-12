From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2
 < v3.9.0
Date: Thu, 12 Jun 2014 11:22:17 -0700 (PDT)
Message-ID: <20140612.112217.526220278608582600.davem@davemloft.net>
References: <1401279319-29088-1-git-send-email-mschmidt@redhat.com>
	<20140530.174248.715408523447246496.davem@davemloft.net>
	<538DBDB3.7030505@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	alexander.h.duyck@intel.com, michael.riesch@omicron.at,
	torvalds@linux-foundation.org
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaFLSWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 14:22:18 -0400
In-Reply-To: <538DBDB3.7030505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue, 03 Jun 2014 14:21:07 +0200

> the old version of the userspace tool did what it had to do in order to
> work with a contemporary kernel. You can call that a bug, but the fact
> is that it used to work that way.
> 
> I do not see a difference between "catering to a user tool bug" and
> "not breaking applications, whether we like them or not" (paraphrasing
> Linus's message on this very mailing list just 10 days ago).

I applied your patch and queued it up for -stable, thanks for persevering :)
