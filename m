From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CIPSO]: Relax too much careful cipso hash function.
Date: Tue, 13 May 2008 23:24:05 -0700 (PDT)
Message-ID: <20080513.232405.32321998.davem@davemloft.net>
References: <4829937D.9070409@openvz.org>
	<200805131434.44463.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758662AbYENGYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 02:24:10 -0400
In-Reply-To: <200805131434.44463.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 13 May 2008 14:34:44 -0400

> On Tuesday 13 May 2008 9:11:25 am Pavel Emelyanov wrote:
> > The cipso_v4_cache is allocated to contain CIPSO_V4_CACHE_BUCKETS
> > buckets. The CIPSO_V4_CACHE_BUCKETS = 1 << CIPSO_V4_CACHE_BUCKETBITS,
> > where CIPSO_V4_CACHE_BUCKETBITS = 7.
> >
> > The bucket-selection function for this hash is calculated like this:
> >
> >   bkt = hash & (CIPSO_V4_CACHE_BUCKETBITS - 1);
> >                                      ^^^
> >
> > i.e. picking only 4 buckets of possible 128 :)
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Thanks Pavel, braino on my part.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied, thanks everyone.
