From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 6 Sep 2007 11:41:26 -0400
Message-ID: <20070906154123.GC10317@gospo.rdu.redhat.com>
References: <1189022828.4960.2.camel@dell> <20070906.040235.71121480.davem@davemloft.net> <20070906134508.GA10317@gospo.rdu.redhat.com> <20070906.073423.74747465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421AbXIFPla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 11:41:30 -0400
Content-Disposition: inline
In-Reply-To: <20070906.073423.74747465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 07:34:23AM -0700, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Thu, 6 Sep 2007 09:45:16 -0400
> 
> > Is is really necessary to get rid of the HT1000 patch?
> 
> Yes, absolutely and without a single doubt.
> 
> > commit e3008dedff4bdc96a5f67224cd3d8d12237082a0
> > Author: Andy Gospodarek <andy@greyhouse.net>
> > Date:   Thu May 10 22:58:57 2007 -0700
> > 
> >     PCI: disable MSI by default on systems with Serverworks HT1000 chips
> > 
> > This patch was designed to address tg3 and bnx2 messages printed on
> > systems with HT1000 chips IIRC.  Are we going back to those messages on
> > bnx2 or is there a workaround in that driver needed too?
> 
> Every report of that problem is with tg3 chips afflicted by this
> INTX bug which is now worked around properly.
> 

Not according to this:

https://bugzilla.redhat.com/show_bug.cgi?id=227657

Which was precisely why I chose to look at it as a chipset issue.

> Even my Niagara T1000 box was hit by this absolutely stupid and
> wrong MSI quirk, which is how I found this problem to begin with.
> 
> I'm reverting it.
> 

If that's the case, do we need to consider that some of the bnx2
hardware (like in this case the 5706) needs a similar workaround?

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
