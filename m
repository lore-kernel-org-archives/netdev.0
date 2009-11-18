From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] macvlan: export macvlan mode through netlink
Date: Wed, 18 Nov 2009 10:59:45 +0100
Message-ID: <200911181059.45331.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-4-git-send-email-arnd@arndb.de> <4B0398D4.8030904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:53621 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbZKRJ7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 04:59:50 -0500
In-Reply-To: <4B0398D4.8030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 November 2009, Eric Dumazet wrote:
> > --- a/drivers/net/macvlan.c
> > +++ b/drivers/net/macvlan.c
> > @@ -33,12 +33,6 @@
> >  
> >  #define MACVLAN_HASH_SIZE    (1 << BITS_PER_BYTE)
> >  
> > -enum macvlan_type {
> > -     MACVLAN_PRIVATE         = 1,
> > -     MACVLAN_VEPA            = 2,
> > -     MACVLAN_BRIDGE          = 4,
> > -};
> 
> I realize you defined MACVLAN_PRIVATE in patch 2, but used MACVLAN_MODE_PRIVATE,
> so patch 2 is not compilable and breaks bisection ?
> 

Hmm, right. I'll fix that up as well.

Thanks,

	Arnd <><
