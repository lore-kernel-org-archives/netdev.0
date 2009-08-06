From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 3/3] documentation: fix wrt. headers rename
Date: Thu, 6 Aug 2009 13:26:17 +0400
Message-ID: <20090806092617.GA9209@doriath.ww600.siemens.net>
References: <1249457297-8355-2-git-send-email-dbaryshkov@gmail.com>
 <1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
 <1249457297-8355-4-git-send-email-dbaryshkov@gmail.com>
 <20090805.202226.24204308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:63597 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbZHFJ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 05:26:43 -0400
Received: by ewy10 with SMTP id 10so626734ewy.37
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2009 02:26:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090805.202226.24204308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 08:22:26PM -0700, David Miller wrote:
> From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Date: Wed,  5 Aug 2009 11:28:17 +0400
> 
> > Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> 
> What are you generating these patches against?
> 
> > @@ -72,5 +72,4 @@ SoftMAC
> >  We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
> >  in software. This is currently WIP.
> >  
> > -See header include/net/ieee802154/mac802154.h and several drivers in
> > -drivers/ieee802154/
> > +See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
> 
> In net-2.6, and in Linus's tree as well, that first sentence quoted has
> a typo, "implementing" is misspelled, but in whatever you're patching
> against the misspelling is fixed.
> 
> Looking at your pull request:
> 
> --------------------
> The following changes since commit db71789c01ae7b641f83c5aa64e7df25122f4b28:
>   David S. Miller (1):
>         xfrm6: Fix xfrm6_policy.c build when SYSCTL disabled.
> --------------------
> 
> You're submitting these for net-next-2.6?  Didn't we just go back and
> forth about trimming this patch series down to only pure bug fixes so
> that they could go into net-2.6?  Given that, why are you generating
> this stuff against net-next-2.6?

Damn. It seems I missed the difference between net-next-2.6 and net-2.6.

BTW: how should I differentiate my poll requests for net-next-2.6 and
for net-2.6 ?

-- 
With best wishes
Dmitry

