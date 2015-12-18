From: Florian Westphal <fw@strlen.de>
Subject: Re: Instantaneous Threshold ECN marking for DCTCP
Date: Fri, 18 Dec 2015 13:49:58 +0100
Message-ID: <20151218124958.GC3198@breakpoint.cc>
References: <CADn3pMdDr=MmTyeZJ0ofacy+gcTC2qKJpWxp9gdBCpr+cfJzHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bryce Cronkite-Ratcliff <brycecr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39314 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbbLRMuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 07:50:00 -0500
Content-Disposition: inline
In-Reply-To: <CADn3pMdDr=MmTyeZJ0ofacy+gcTC2qKJpWxp9gdBCpr+cfJzHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryce Cronkite-Ratcliff <brycecr@gmail.com> wrote:
> Is there a way to achieve this simple threshold-ECN marking AQM with
> tc, or another approach?

Use codel or fq-codel with 'ce_threshold' added by Eric Dumazet, see

https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=df1c7d9138eafd5b96e81040b0c1475b6d73d158
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=80ba92fa1a92dea128283f69f55b02242e213650
