From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net 03/05: fib_rules: add oif classification
Date: Tue, 1 Dec 2009 09:48:00 +0000
Message-ID: <20091201094800.GB7573@ff.dom.local>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175533.7555.35189.sendpatchset@x2.localnet> <4B1447DD.1070904@gmail.com> <4B14E2B8.3030507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:44378 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737AbZLAJsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 04:48:00 -0500
Received: by fxm5 with SMTP id 5so4666391fxm.28
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 01:48:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B14E2B8.3030507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 10:32:40AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > Patrick McHardy wrote, On 11/30/2009 06:55 PM:
> >   
> >> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> >> index 62bebcb..d4e875a 100644
> >> --- a/include/net/fib_rules.h
> >> +++ b/include/net/fib_rules.h
> >> @@ -11,6 +11,7 @@ struct fib_rule {
> >>  	struct list_head	list;
> >>  	atomic_t		refcnt;
> >>  	int			iifindex;
> >> +	int			oifindex;
> >>     
> >
> > Doesn't it "break" the cacheline fix from 01/05?
> 
> No, there's a 4 byte hole which is plugged by this:
> 

Right, I missed it, sorry.

Jarek P.
