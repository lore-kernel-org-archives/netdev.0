From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 08:57:15 +0200
Message-ID: <20110524065715.GB12816@elte.hu>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
 <20110524.011330.1077020828173889583.davem@davemloft.net>
 <1306217837.2638.36.camel@edumazet-laptop>
 <1306218793.2298.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	a.p.zijlstra@chello.nl, eparis@parisplace.org,
	eugeneteo@kernel.org, jmorris@namei.org, kees.cook@canonical.com,
	tgraf@infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:35396 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854Ab1EXG6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 02:58:15 -0400
Content-Disposition: inline
In-Reply-To: <1306218793.2298.10.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joe Perches <joe@perches.com> wrote:

> Maybe for clarity it'd be better to use a switch/case
> or something like:
> 
> 	if (kptr_restrict == 0)
> 		return ptr;
> 	if (ptr_restrict == 1 &&
> 	    has_capability_noaudit(current, CAP_SYSLOG))
> 		return ptr;
> 	return NULL;

While not breaking that line really - so something like:

	if (kptr_restrict == 0)
		return ptr;

	if (kptr_restrict == 1 && has_capability_noaudit(current, CAP_SYSLOG))
		return ptr;

	return NULL;

Thanks,

	Ingo
