From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 11:49:22 +0000
Message-ID: <20091104114922.GA8176@ff.dom.local>
References: <20091103080022.GA6718@ff.dom.local> <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com> <20091103100538.GC6718@ff.dom.local> <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com> <20091103230035.GA2352@ami.dom.local> <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com> <20091104082808.GA6224@ff.dom.local> <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com> <20091104104245.GB6224@ff.dom.local> <412e6f7f0911040321o22c536fdid078f6d2225a90a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:53420 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755415AbZKDLtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 06:49:22 -0500
Received: by bwz27 with SMTP id 27so8754153bwz.21
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 03:49:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911040321o22c536fdid078f6d2225a90a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 04, 2009 at 07:21:48PM +0800, Changli Gao wrote:
...
> > cl->mbuffer is only to limit some extreme effects, so more of an
> > exception, not a main tool of rate control. (It really should be
> > useless most of the time if classes don't stop sending and aren't
> > deprived of their full rate for really long time.)
> >
> 
> I don't think so. Although a class's tokens may be negative, but its
> ctokens may be positive. Charging its tokens is to prevent its cmode
> from being changed to HTB_CAN_SEND from HTB_CANT_SEND directly.

I think, you should really better show some tests proving your patch
is needed and doesn't affect a case I described, instead of trying to
discuss the meaninig of all HTB variables here.

Regards,
Jarek P.
