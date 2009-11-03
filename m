From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Tue, 3 Nov 2009 10:05:38 +0000
Message-ID: <20091103100538.GC6718@ff.dom.local>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local> <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:65370 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbZKCKFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:05:39 -0500
Received: by bwz27 with SMTP id 27so7369988bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 02:05:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2009 at 05:47:17PM +0800, Changli Gao wrote:
> On Tue, Nov 3, 2009 at 4:00 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> >
> >> It means that a class, which sends packets
> >> in ceil rate, can also enter HTB_CAN_SEND state now and then.
> >
> > Yes, a class is entitled to send on it's own then with it's guaranteed
> > rate, without depending on borrowing.
> 
> I don't think so. The class should _NOT_ enter HTB_CAN_SEND mode when
> its data rate is higher than its rate specification. In other word, a
> class should enter HTB_CAN_SEND mode only when its data rate isn't
> higher than its rate specification. Otherwise, it will get additional
> tokens and reach a higher data rate than its ceil specification. This
> may affect other classes.

The ceil specification is controlled only by ctokens, which are always
updated, so no such risk.

Regards,
Jarek P.
