From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 16:27:29 -0400
Message-ID: <20070906202728.GB10916@gospo.rdu.redhat.com>
References: <20070906.073423.74747465.davem@davemloft.net> <20070906154123.GC10317@gospo.rdu.redhat.com> <1189105530.4852.8.camel@dell> <20070906.125019.104036964.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, andy@greyhouse.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbXIFU1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 16:27:36 -0400
Content-Disposition: inline
In-Reply-To: <20070906.125019.104036964.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 12:50:19PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 06 Sep 2007 12:05:30 -0700
> 
> > The HT1000 bridge may very well have an MSI issue.  I'm checking with
> > ServerWorks and I will do some testing to confirm.  If confirmed, we can
> > disable MSI behind the HT1000 bridge instead of globally.  The 5714
> > issue is not caused by the HT1000 as it is not behind the HT1000.
> 
> What I'm going to do at this point is just merge the tg3
> fix into the current 2.6.23 tree right now.
> 
> Meanwhile I'll have the HT1000 MSI quirk revert ready and,
> unless we find a reason not to, I'll ask Greg KH to merge
> that patch into 2.6.24
> 
> It seems the safest and most reasonable way to handle this
> right now.

Sounds great.  Hopefully Michael will hear something back from his folks
before too long and we can use whatever they suggest instead of just the
revert.

