From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take2][NET_SCHED] cls_u32: refcounting fix for
 u32_delete()
Date: Sat, 12 Apr 2008 18:37:23 -0700 (PDT)
Message-ID: <20080412.183723.161646190.davem@davemloft.net>
References: <47FF662B.2040302@trash.net>
	<20080411134818.GA3776@ff.dom.local>
	<1207922127.4419.85.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754837AbYDMBhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 21:37:22 -0400
In-Reply-To: <1207922127.4419.85.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Fri, 11 Apr 2008 09:55:27 -0400

> On Fri, 2008-11-04 at 13:48 +0000, Jarek Poplawski wrote:
> > On Fri, Apr 11, 2008 at 03:22:51PM +0200, Patrick McHardy wrote:
> > ...
> > > I'd suggest to behave similar to qdiscs when trying to
> > > removing classes that are still referenced, return -EBUSY.
> > 
> > Of course you are right!
> > 
> > Jarek P.
> > 
> > -------------------> (take 2)
> > 
> > [NET_SCHED] cls_u32: refcounting fix for u32_delete()
> > 
> > Deleting of nonroot hnodes mostly doesn't work in u32_delete():
> > refcnt == 1 is expected, but such hnodes' refcnts are initialized
> > with 0 and charged only with "link" nodes. Now they'll start with
> > 1 like usual. Thanks to Patrick McHardy for an improving suggestion.
> > 
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Thanks as always Jarek.
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks everyone.
