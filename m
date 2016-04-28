From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] ip_tunnel: fix preempt warning in ip tunnel
 creation/updating
Date: Thu, 28 Apr 2016 16:11:16 +0200
Message-ID: <1461852676.4802.31.camel@redhat.com>
References: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
	 <1461845394.5535.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, tgraf@suug.ch,
	pshelar@nicira.com, jbenc@redhat.com, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbcD1OLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 10:11:21 -0400
In-Reply-To: <1461845394.5535.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 05:09 -0700, Eric Dumazet wrote:
> On Thu, 2016-04-28 at 11:04 +0200, Paolo Abeni wrote:
> > After the commit e09acddf873b ("ip_tunnel: replace dst_cache with generic
> > implementation"), a preemption debug warning is triggered on ip4
> > tunnels updating; the dst cache helper needs to be invoked in unpreemptible
> > context.
> > 
> > We don't need to load the cache on tunnel update, so this commit fixes
> > the warning replacing the load with a dst cache reset, which is
> > preempt safe.
> > 
> > Fixes: e09acddf873b ("ip_tunnel: replace dst_cache with generic
> > implementation")
> > 
> > Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> 
> Seems good to me, thanks.
> 
> Note that the Fixes: tag should not be followed by a blank line.
> (And presumably no line wrap is necessary)
> It really is part of the standard set of tags.
> They should be grouped together.

Oops, I missed that points and checkpatch.pl did not help. 
Thank you for the advice.

Paolo
