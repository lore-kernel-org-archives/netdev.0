From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps with nanosec resolution
Date: Thu, 8 Mar 2007 17:42:11 +0100
Message-ID: <200703081742.11720.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200703081517.57539.dada1@cosmosbay.com> <45F039BF.3070309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:49794 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520AbXCHQmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 11:42:06 -0500
In-Reply-To: <45F039BF.3070309@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 March 2007 17:28, Patrick McHardy wrote:
> Eric Dumazet wrote:
> > --- a/include/asm-mips/sockios.h
> > +++ b/include/asm-mips/sockios.h
> > @@ -20,6 +20,7 @@ #define SIOCATMARK	_IOR('s', 7, int)
> >  #define SIOCSPGRP	_IOW('s', 8, pid_t)
> >  #define SIOCGPGRP	_IOR('s', 9, pid_t)
> >
> > -#define SIOCGSTAMP	0x8906			/* Get stamp - linux-specific */
> > +#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
> > +#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
>
> You might want to CC linux-arch or the architecture maintainers.
> Last time I changed something in this area I got complaints
> because it affected syscall emulation for non-Linux binaries
> or something like that.

I really dont see how this change could break syscall emulation for non-Linux 
binaries. SIOCGSTAMP{NS} is linux specific.

Could you please give the context of your past problems ?

Thank you
