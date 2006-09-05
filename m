From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: ProxyARP and IPSec
Date: Tue, 5 Sep 2006 13:05:30 +0400
Message-ID: <20060905090530.GA17104@ms2.inr.ac.ru>
References: <44ECFCF1.10500@zytor.com> <44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net> <44ED2797.4070304@zytor.com> <20060824125046.GA25439@ms2.inr.ac.ru> <44EFCB0F.5080506@zytor.com> <17657.42254.455342.157858@localhost.localdomain> <44F9BFC2.4050001@zytor.com> <20060904222722.GA24078@ms2.inr.ac.ru> <44FD0759.8070307@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:23759 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S965065AbWIEJFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 05:05:49 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
Content-Disposition: inline
In-Reply-To: <44FD0759.8070307@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> >1. Probably, will not accept fragmented frames, because IPsec cannot
> >   handle them
...
> I'm clearly failing to understand where, exactly, the problems lie.  I 
> would appreciate any pointers and/or clue transfusion...

I said "probably".

Look into old rfc2401, search for word "fragment".
Then search for the same word in new rfc4301. All those 100K of new text
deal with various design bugs in IPsec, mostly with pathologies encountered
in the case of security gateways. (Some section there are real fun: f.e.
look at section 7.2)

With this amount of thin places, there are no chances it will interoperate,
unless you use the most conservative approach.

My opinion? Scared. :-)

Alexey
