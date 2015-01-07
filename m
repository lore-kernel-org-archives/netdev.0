From: Florian Westphal <fw@strlen.de>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Wed, 7 Jan 2015 23:13:09 +0100
Message-ID: <20150107221309.GG11324@breakpoint.cc>
References: <20150107215331.GA19197@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44389 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754478AbbAGWNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:13:11 -0500
Content-Disposition: inline
In-Reply-To: <20150107215331.GA19197@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vadim Kochan <vadim4j@gmail.com> wrote:
> I'd like to make possible to generate plot info about class hierarchy
> with qdisc, filters, stats info, but I see that all this staffs are
> printed to 'FILE *fp' which makes this hard to implement and seems to me
> that it should be changed to be printed to 'char *s' (memory safety
> should be considered by asprintf or similar), so this is a big change
> but all this is possible and I ready to do it, but before do it I'd like
> to ask if this could be acceptable as idea.
> 
> BUT maybe someone can advise me easier solution ?

Would fmemopen/open_memstream(3) do what you want?
