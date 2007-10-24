From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 21:14:37 +0200
Message-ID: <20071024191437.GF30533@stusta.de>
References: <20071024162410.GE30533@stusta.de> <OFD68B1480.9D9C7453-ON8825737E.0068B005-8825737E.0068FB84@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:57567 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753391AbXJXTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 15:14:08 -0400
Content-Disposition: inline
In-Reply-To: <OFD68B1480.9D9C7453-ON8825737E.0068B005-8825737E.0068FB84@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 24, 2007 at 12:07:45PM -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 10/24/2007 09:24:10 AM:
> 
> > This patch removes the unused EXPORT_SYMBOL(icmpmsg_statistics).
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > 
> > ---
> > 4ce74657ac0b1bdcb4c7bc359d05643f8cc4a08b 
> > diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> > index 272c69e..233de06 100644
> > --- a/net/ipv4/icmp.c
> > +++ b/net/ipv4/icmp.c
> > @@ -1104,5 +1104,4 @@ void __init icmp_init(struct net_proto_family 
> *ops)
> >  EXPORT_SYMBOL(icmp_err_convert);
> >  EXPORT_SYMBOL(icmp_send);
> >  EXPORT_SYMBOL(icmp_statistics);
> > -EXPORT_SYMBOL(icmpmsg_statistics);
> >  EXPORT_SYMBOL(xrlim_allow);
> 
>         "icmpmsg_statistics" belongs with (and replaces some of the 
> old...)
> "icmp_statistics". I'm not sure that any modules use it, but I think you
> should remove both or neither.

icmp_statistics is used by the dccp_ipv4 and sctp modules.

icmpmsg_statistics is not used by any modules.

>                                                                 +-DLS

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

