From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Wed, 14 Jan 2015 18:13:27 +0200
Message-ID: <20150114161327.GA7965@angus-think.wlc.globallogic.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
 <20150113172837.793f0969@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:60657 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbbANQX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 11:23:59 -0500
Received: by mail-lb0-f176.google.com with SMTP id p9so8819979lbv.7
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 08:23:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113172837.793f0969@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2015 at 05:28:37PM -0800, Stephen Hemminger wrote:
> On Wed,  7 Jan 2015 13:04:19 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
> > 
> > 'ip netns exec' executes command forcely on eacn nsname.
> > 
> > Vadim Kochan (3):
> >   lib: Exec func on each netns
> >   ip netns: Allow exec on each netns
> >   ip netns: Delete all netns
> > 
> >  include/namespace.h |  6 ++++
> >  include/utils.h     |  5 +++
> >  ip/ipnetns.c        | 96 ++++++++++++++++++++++++++++++++---------------------
> >  lib/namespace.c     | 22 ++++++++++++
> >  lib/utils.c         | 28 ++++++++++++++++
> >  man/man8/ip-netns.8 | 26 ++++++++++++---
> >  6 files changed, 141 insertions(+), 42 deletions(-)
> > 
> 
> It is a useful concept but as others have pointed out the idea of reserving
> a keyword 'all' at this point is likely to cause somebody to break.
> So sorry.
OK, then what about additional option like:

    $ ip -all netns exec ...

?

Thanks,
