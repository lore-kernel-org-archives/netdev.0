From: Julian Anastasov <ja@ssi.bg>
Subject: Re: strange routing issue--packets stop getting forwarded for a live
 connection
Date: Sun, 21 Aug 2011 12:02:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108211142180.1581@ja.ssi.bg>
References: <4E506A46.6060407@fatooh.org> <alpine.LFD.2.00.1108210924010.1581@ja.ssi.bg> <4E50BDFB.7050502@fatooh.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52561 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab1HUI5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 04:57:09 -0400
In-Reply-To: <4E50BDFB.7050502@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 21 Aug 2011, Corey Hickey wrote:

> >> 3. MTU size; 1500 on eth0 and 1406 on tun0. Bigger packets have been
> >> transferred fine.
> > 
> > 	Lower MTU, it can be PMTUD problem. At 04:50:24.112658
> > I see 7801:9169 is 1420 bytes and no ICMP FRAG NEEDED is generated.
> > May be these two regressions explain it:
> > 
> > http://marc.info/?l=linux-netdev&m=131342172722536&w=2
> > 
> > 	There are 2 fixes you can try or more recent kernel
> > tree, for example 3.1-rc2 has the fixes.
> 
> Many thanks for your reply--it looks like you're on to something. You
> didn't specify which interface to lower the MTU on, so I tried them each
> in turn, and found that lowering the MTU on the client machine to 1406
> (matching tun0 on the router) did indeed solve the problem. That makes
> sense in retrospect.

	I just wanted to note the difference in MTUs
as a possible cause that triggers the problem. And after
your confirmation I think the new/patched kernel should work
without playing with MTUs.

> It's a bit late at night for me to be patching my kernel, but I'll see
> if I can do it tomorrow.
> 
> Thanks again, and I'll let you know how it turns out.
> 
> -Corey

Regards

--
Julian Anastasov <ja@ssi.bg>
