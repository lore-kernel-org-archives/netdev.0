From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/3] improve MACsec support
Date: Wed, 27 Jul 2016 11:19:50 -0700
Message-ID: <20160727111950.63bc8967@xeon-e3>
References: <cover.1469520298.git.dcaratti@redhat.com>
	<20160726134439.GA27771@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Davide Caratti <dcaratti@redhat.com>,
	Stephen Hemminger <shemming@brocade.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34553 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbcG0STh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 14:19:37 -0400
Received: by mail-pf0-f177.google.com with SMTP id p64so13266050pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Jul 2016 11:19:37 -0700 (PDT)
In-Reply-To: <20160726134439.GA27771@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2016 15:44:39 +0200
Sabrina Dubroca <sd@queasysnail.net> wrote:

> 2016-07-26, 11:03:17 +0200, Davide Caratti wrote:
> > parsing of 'cipher' and 'icvlen' arguments has been improved; while at it,
> > a couple of missing printouts have been added to usage() functions in 
> > "ip addr help" and "ip link help". Finally, some errors in the man pages
> > have been fixed.
> > 
> > Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> > 
> > Davide Caratti (3):
> >   man: macsec: fix macsec related typos
> >   ip {link,address}: add 'macsec' item to TYPE list
> >   macsec: cipher and icvlen can be set separately
> > 
> >  ip/ipaddress.c           |  2 +-
> >  ip/iplink.c              |  2 +-
> >  ip/ipmacsec.c            | 52 ++++++++++++++++--------------------------------
> >  man/man8/ip-address.8.in |  3 ++-
> >  man/man8/ip-link.8.in    | 17 +++++++++++-----
> >  man/man8/ip-macsec.8     | 13 ++++++++----
> >  6 files changed, 42 insertions(+), 47 deletions(-)  
> 
> Acked-by: Sabrina Dubroca <sd@queasysnail.net>
> 
> Stephen, can this go in before the 4.7 release?  This fixes parsing
> bugs and docs, it would be nice to have this.
> 
> 
> Thanks,
> 

Will try, still have a couple open things for 4.7
