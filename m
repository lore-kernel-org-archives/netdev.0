From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Make XFRM_ACQ_EXPIRES tweakable
Date: Thu, 24 May 2007 23:41:19 -0700 (PDT)
Message-ID: <20070524.234119.112621013.davem@davemloft.net>
References: <20070524.221304.36926453.davem@davemloft.net>
	<46567174.5020509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753268AbXEYGlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 02:41:15 -0400
In-Reply-To: <46567174.5020509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 25 May 2007 07:17:40 +0200

> > --- a/net/xfrm/xfrm_state.c
> > +++ b/net/xfrm/xfrm_state.c
> > @@ -33,6 +33,8 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_etime);
> >  u32 sysctl_xfrm_aevent_rseqth = XFRM_AE_SEQT_SIZE;
> >  EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth);
> >  
> > +u32 sysctl_xfrm_acq_expires = 30;
> > +
> 
> You already knows what is my objection :)

There are two other sysctls right above it which aren't
marked read mostly either, sorry about that, I'll fix
them all.

