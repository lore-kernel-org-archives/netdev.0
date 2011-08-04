From: Florian Mickler <florian@mickler.org>
Subject: Re: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to be
 broken.
Date: Thu, 4 Aug 2011 21:12:03 +0200
Message-ID: <20110804211203.2e6b1b45@schatten.dmk.lab>
References: <20110804193107.68d93727@schatten.dmk.lab>
	<alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hilld@binarystorm.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	bugzilla-daemon@bugzilla.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ist.d-labs.de ([213.239.218.44]:37956 "EHLO mx01.d-labs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912Ab1HDTMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 15:12:10 -0400
In-Reply-To: <alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Aug 2011 21:38:48 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 
> 	Hello,
> 
> On Thu, 4 Aug 2011, Florian Mickler wrote:
> 
> > Can someone take a look at this regression?
> > 
> > Begin forwarded message:
> > 
> > Date: Thu, 28 Jul 2011 04:51:12 GMT
> > From: bugzilla-daemon@bugzilla.kernel.org
> > To: florian@mickler.org
> > Subject: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to be
> > broken.
> > 
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=39132
> 
> 	So, problem points again to
> "Fix ip_route_me_harder triggering ip_rt_bug" ? May be
> David C. Hill or Florian can provide some information, eg. is
> tproxy used, what NAT rules are used, any rules in OUTPUT
> hooks (NAT/mangle) and which packets are dropped.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

That would have to come from David C. Hill, since I'm not expiriencing
this bug. 

Regards,
Flo

p.s.: I added the bugzilla daemon to the cc in the hope that this mail
will land as a comment in there. 
