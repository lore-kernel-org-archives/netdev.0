From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 14:26:52 -0400
Message-ID: <20070906182650.GD10317@gospo.rdu.redhat.com>
References: <1189022828.4960.2.camel@dell> <20070906.040235.71121480.davem@davemloft.net> <20070906134508.GA10317@gospo.rdu.redhat.com> <20070906.073423.74747465.davem@davemloft.net> <20070906154123.GC10317@gospo.rdu.redhat.com> <1189105530.4852.8.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45461 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbXIFS05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 14:26:57 -0400
Content-Disposition: inline
In-Reply-To: <1189105530.4852.8.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 12:05:30PM -0700, Michael Chan wrote:
> On Thu, 2007-09-06 at 11:41 -0400, Andy Gospodarek wrote:
> > On Thu, Sep 06, 2007 at 07:34:23AM -0700, David Miller wrote:
> > > From: Andy Gospodarek <andy@greyhouse.net>
> > > Date: Thu, 6 Sep 2007 09:45:16 -0400
> > > 
> > > > Is is really necessary to get rid of the HT1000 patch?
> > > 
> > > Yes, absolutely and without a single doubt.
> > > 
> > > > commit e3008dedff4bdc96a5f67224cd3d8d12237082a0
> > > > Author: Andy Gospodarek <andy@greyhouse.net>
> > > > Date:   Thu May 10 22:58:57 2007 -0700
> > > > 
> > > >     PCI: disable MSI by default on systems with Serverworks HT1000 chips
> > > > 
> > > > This patch was designed to address tg3 and bnx2 messages printed on
> > > > systems with HT1000 chips IIRC.  Are we going back to those messages on
> > > > bnx2 or is there a workaround in that driver needed too?
> > > 
> > > Every report of that problem is with tg3 chips afflicted by this
> > > INTX bug which is now worked around properly.
> > > 
> > 
> > Not according to this:
> > 
> > https://bugzilla.redhat.com/show_bug.cgi?id=227657
> > 
> > Which was precisely why I chose to look at it as a chipset issue.
> 
> The HT1000 bridge may very well have an MSI issue.  I'm checking with
> ServerWorks and I will do some testing to confirm.  If confirmed, we can
> disable MSI behind the HT1000 bridge instead of globally.  The 5714
> issue is not caused by the HT1000 as it is not behind the HT1000.
> 

Thanks for checking that out.  You can probably get the information more
easily than I can. ;-)

