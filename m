From: kmathis <kmathis@chokepoint.net>
Subject: Re: [PATCH ipvs v2] ipvs: Add simple weighted failover scheduler
Date: Wed, 10 Sep 2014 09:22:30 -0400
Message-ID: <20140910132230.GA11463@kmathis.internal.monetra.com>
References: <20140909132015.GA21984@kmathis.internal.monetra.com>
 <alpine.LFD.2.11.1409092247220.4943@ja.home.ssi.bg>
 <20140910002108.GG16682@verge.net.au>
 <20140910061708.GD10233@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:59846 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaIJNWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 09:22:33 -0400
Received: by mail-yh0-f46.google.com with SMTP id f73so2551409yha.33
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 06:22:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140910061708.GD10233@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From what I can tell, ipvsadm doesn't need any specific code updates.
The only place that the schedulers are actually listed is in the man page
and the SCHEDULERS file, but I can submit a change to ensure it's
listed. When I tested with keepalived, the failover (fo) module showed
up properly under ipvsadm as well without any modifications.

On Wed, Sep 10, 2014 at 03:17:09PM +0900, Simon Horman wrote:
> On Wed, Sep 10, 2014 at 09:21:09AM +0900, Simon Horman wrote:
> > On Tue, Sep 09, 2014 at 10:55:42PM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Tue, 9 Sep 2014, Kenny Mathis wrote:
> > > 
> > > > Please consider this patch for addition in 3.17
> > 
> > There is no need to update this patch, but for reference
> > the line above belongs below scissors ('---') below your Signed-off-by line.
> > i.e. just above the diffstat below.
> > 
> > That way git will automatically remove it when you apply your patch.
> > 
> > > > Add simple weighted IPVS failover support to the Linux kernel. All
> > > > other scheduling modules implement some form of load balancing, while
> > > > this offers a simple failover solution. Connections are directed to
> > > > the appropriate server based solely on highest weight value and server
> > > > availability. Tested functionality with keepalived.
> > > > 
> > > > Signed-off-by: Kenny Mathis <kmathis@chokepoint.net>
> > > 
> > > 	Looks good to me, thanks!
> > > 
> > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	Simon, you can apply it to ipvs-next if there are
> > > no any objections.
> > 
> > I have no objections. I have applied it.
> 
> Kenny, are you planning an update to ipvsadm to allow it to use
> the new scheduler?
