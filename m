From: Florian Westphal <fw@strlen.de>
Subject: Re: WARNING at net/ipv4/netfilter/ip_tables.c:530
Date: Tue, 25 Aug 2015 20:31:27 +0200
Message-ID: <20150825183127.GC5259@breakpoint.cc>
References: <CAHA+R7NZrw-jc0r8HvhN7b6BmV32w+_ONZ9Ft8vJCgsF332AOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51918 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751816AbbHYSba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:31:30 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7NZrw-jc0r8HvhN7b6BmV32w+_ONZ9Ft8vJCgsF332AOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> wrote:
> Your commit 98d1bd802cdbc8f56868fae51edec13e86b59515 (netfilter:
> xtables: compute exact size needed for jumpstack) introduced the
> following kernel warning during boot.
> 
> It looks like the if check inside mark_source_chains() isn't correct,
> this causes calldepth not increased as expected, but I don't have time
> to dig this.
> 
> Let me know if you need more information.

No, Hannes reported something similar.

I'm working on it.

Thanks,
Florian
