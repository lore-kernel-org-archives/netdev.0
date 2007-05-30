From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers are removed
Date: Wed, 30 May 2007 11:38:28 +0200
Message-ID: <200705301138.29582@nienna>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli> <Pine.LNX.4.58.0705181043390.2665@u.domain.uli> <20070518.020525.28394540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, kaber@trash.net, horms@verge.net.au,
	jkrzyszt@tis.icnet.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:2128 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbXE3KAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 06:00:55 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 42D4FB55A0
	for <netdev@vger.kernel.org>; Wed, 30 May 2007 11:38:31 +0200 (CEST)
In-Reply-To: <20070518.020525.28394540.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Friday 18 May 2007 11:05, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Fri, 18 May 2007 11:40:54 +0300 (EEST)
>
> > On Thu, 17 May 2007, Patrick McHardy wrote:
> > > In any case some better solution than the current one needs to be
> > > found, allowing users to send spoofed packets is far worse than
> > > using a non-desired source address for ICMP packets.
> >
> > 	yes, I would prefer the sysctl_ip_nonlocal_bind change to be
> > removed until such solution is found.
>
> Ok, I'll revert it.

  I'm just about to publish the next round of tproxy patches (with the 
routing code modifications completely removed), but this issue is still 
present.

  I've posted a few patches making omitting this check possible 
selectively back in March. Do those changes look acceptable?

  http://marc.info/?l=linux-netdev&m=117310979823297&w=3

  And the related socket layer changes:

  http://marc.info/?l=linux-netdev&m=117310979815374&w=3
  http://marc.info/?l=linux-netdev&m=117310979902806&w=3
  http://marc.info/?l=linux-netdev&m=117310980027541&w=3

-- 
 Regards,
  Krisztian Kovacs
