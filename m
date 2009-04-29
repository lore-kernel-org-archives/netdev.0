From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 09:35:39 +0200
Message-ID: <20090429073539.GR27382@one.firstfloor.org>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <20090429002049.4bbc8105.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org,
	Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33542 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432AbZD2Hbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:31:36 -0400
Content-Disposition: inline
In-Reply-To: <20090429002049.4bbc8105.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Seems that this is a virtuous patch even though Christoph is struggling
> a bit to test it?

The main drawback is that the select/poll data structures will get
larger. That could cause regression in theory. But I suspect
the win in some situations is still worth it. Of course
it would be nice if it handled more situations (like
multiple reader etc.)

-Andi
