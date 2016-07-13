From: Florian Westphal <fw@strlen.de>
Subject: Re: 4.6.3 panic on nf_ct_delete (nf_conntrack)
Date: Wed, 13 Jul 2016 22:21:13 +0200
Message-ID: <20160713202113.GA4198@breakpoint.cc>
References: <df376f88504cb0f20b20acf42962c16d@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: nuclearcat@nuclearcat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43567 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750897AbcGMUVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 16:21:19 -0400
Content-Disposition: inline
In-Reply-To: <df376f88504cb0f20b20acf42962c16d@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nuclearcat@nuclearcat.com <nuclearcat@nuclearcat.com> wrote:
> Workload: pppoe server, 5k users on ppp interfaces. No actual SNAT/DNAT, but
> using connmark and REDIRECT
> 
> [176412.990104] general protection fault: 0000 [#1]
> SMP

I assume that you did not see this before.

What was the last kernel version where you did not run into this?

Might help to narrow things down.
