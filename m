From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [iproute PATCH 0/3] improve MACsec support
Date: Tue, 26 Jul 2016 15:44:39 +0200
Message-ID: <20160726134439.GA27771@bistromath.localdomain>
References: <cover.1469520298.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemming@brocade.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756175AbcGZNon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 09:44:43 -0400
Content-Disposition: inline
In-Reply-To: <cover.1469520298.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-26, 11:03:17 +0200, Davide Caratti wrote:
> parsing of 'cipher' and 'icvlen' arguments has been improved; while at it,
> a couple of missing printouts have been added to usage() functions in 
> "ip addr help" and "ip link help". Finally, some errors in the man pages
> have been fixed.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> 
> Davide Caratti (3):
>   man: macsec: fix macsec related typos
>   ip {link,address}: add 'macsec' item to TYPE list
>   macsec: cipher and icvlen can be set separately
> 
>  ip/ipaddress.c           |  2 +-
>  ip/iplink.c              |  2 +-
>  ip/ipmacsec.c            | 52 ++++++++++++++++--------------------------------
>  man/man8/ip-address.8.in |  3 ++-
>  man/man8/ip-link.8.in    | 17 +++++++++++-----
>  man/man8/ip-macsec.8     | 13 ++++++++----
>  6 files changed, 42 insertions(+), 47 deletions(-)

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

Stephen, can this go in before the 4.7 release?  This fixes parsing
bugs and docs, it would be nice to have this.


Thanks,

-- 
Sabrina
