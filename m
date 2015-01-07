From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Thu, 8 Jan 2015 00:12:57 +0200
Message-ID: <20150107221257.GA23047@angus-think.lan>
References: <20150107215331.GA19197@angus-think.lan>
 <20150107221309.GG11324@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:33392 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbbAGWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:23:21 -0500
Received: by mail-la0-f42.google.com with SMTP id gd6so6273121lab.1
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:23:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150107221309.GG11324@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 11:13:09PM +0100, Florian Westphal wrote:
> Vadim Kochan <vadim4j@gmail.com> wrote:
> > I'd like to make possible to generate plot info about class hierarchy
> > with qdisc, filters, stats info, but I see that all this staffs are
> > printed to 'FILE *fp' which makes this hard to implement and seems to me
> > that it should be changed to be printed to 'char *s' (memory safety
> > should be considered by asprintf or similar), so this is a big change
> > but all this is possible and I ready to do it, but before do it I'd like
> > to ask if this could be acceptable as idea.
> > 
> > BUT maybe someone can advise me easier solution ?
> 
> Would fmemopen/open_memstream(3) do what you want?
I briefly looked on it, and it might help, THANKS A LOT!
