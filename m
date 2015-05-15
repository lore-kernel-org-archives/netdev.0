From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 17:23:31 +0200
Message-ID: <20150515152331.GA17375@via.ecp.fr>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
 <1431401204-731380-6-git-send-email-tom@herbertland.com>
 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
 <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150515143506.GA5019@via.ecp.fr>
 <1431701557.27831.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:57531 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934370AbbEOPXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:23:34 -0400
Content-Disposition: inline
In-Reply-To: <1431701557.27831.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-15, 07:52:37 -0700, Eric Dumazet wrote:
> On Fri, 2015-05-15 at 16:35 +0200, Sabrina Dubroca wrote:
> > Hi Eric,
> > 
> > 2015-05-15, 05:48:07 -0700, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > First one in __skb_checksum_validate_complete() fixes the following
> > > (and other callers)
> > > 
> > > make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_ipv4.o
> > >   CHECK   net/ipv4/tcp_ipv4.c
> > > include/linux/skbuff.h:3052:24: warning: incorrect type in return expression (different base types)
> > > include/linux/skbuff.h:3052:24:    expected restricted __sum16
> > > include/linux/skbuff.h:3052:24:    got int
> > > 
> > > Second is fixing gso_make_checksum() :
> > > 
> > >   CHECK   net/ipv4/gre_offload.c
> > > include/linux/skbuff.h:3360:14: warning: incorrect type in assignment (different base types)
> > > include/linux/skbuff.h:3360:14:    expected unsigned short [unsigned] [usertype] csum
> > > include/linux/skbuff.h:3360:14:    got restricted __sum16
> > > include/linux/skbuff.h:3365:16: warning: incorrect type in return expression (different base types)
> > > include/linux/skbuff.h:3365:16:    expected restricted __sum16
> > > include/linux/skbuff.h:3365:16:    got unsigned short [unsigned] [usertype] csum
> > > 
> > > 
> > > Fixes: 5a21232983aa7 ("net: Support for csum_bad in skbuff")
> > > Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > CC: Tom Herbert <tom@herbertland.com>
> > > ---
> > 
> > That's very similar to what I submitted in February:
> > https://patchwork.ozlabs.org/patch/437332/
> 
> Well, given you did not address David concerns, and Tom apparently does
> not know how to use sparse, I finally gave up.

Sorry :(

But I don't see how doing the same thing for
__skb_checksum_validate_complete will address David's concerns.

I really have no problem with your submission, I just thought that it
might not satisfy David.
