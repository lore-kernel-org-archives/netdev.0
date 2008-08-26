From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 11:32:13 +0000
Message-ID: <20080826113213.GA5991@ff.dom.local>
References: <20080826095126.GA2609@ff.dom.local> <20080826110746.GC2609@ff.dom.local> <20080826111545.GD2609@ff.dom.local> <200808261416.32315.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:24122 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbYHZLce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:32:34 -0400
Received: by ug-out-1314.google.com with SMTP id c2so715954ugf.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:32:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808261416.32315.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 02:16:32PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 26 August 2008, Jarek Poplawski wrote:
> > Hmm.. it isn't actually answer to your question, sorry. As I said
> > before I think we need to have more people interested in using such
> > additional options, and btw. I understood from your message that
> > disabling htb didn't solve the problem?
> >
> > Jarek P.
> Only HTB - no. If i disable softlockup debug - seems the load is less (i must 
> make sure), and if i remove HTB - it is becoming low. I will try to give 
> exact numbers in recent days.
> 

So maybe you could try again this htb patch for limiting
qdisc_watchdog_schedule()?

Jarek P.
