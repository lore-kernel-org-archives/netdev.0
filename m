From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 2/4] sit: support MPLS over IPv4
Date: Thu, 7 Jul 2016 07:37:58 +0200
Message-ID: <20160707053757.GA10002@penelope.isobedori.kobe.vergenet.net>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
 <1467829355-4498-3-git-send-email-simon.horman@netronome.com>
 <20160706.221059.1791526468514384047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33169 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213AbcGGFiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:38:02 -0400
Received: by mail-wm0-f53.google.com with SMTP id r190so753628wmr.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:38:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160706.221059.1791526468514384047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 10:10:59PM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Wed,  6 Jul 2016 20:22:33 +0200
> 
> >  
> > +bool ipip6_valid_ip_proto(u8 ipproto)
> > +{
> > +	return ipproto == IPPROTO_IPV6 ||
> > +		ipproto != IPPROTO_IPIP ||
> > +#if IS_ENABLED(CONFIG_MPLS)
> > +		ipproto == IPPROTO_MPLS ||
> > +#endif
> > +		ipproto == 0;
> > +}
> 
> This returns true any time ipproto is not equal to IPPROTO_IPIP,
> which is probably not what you intended here.

Thanks, I will fix that.
