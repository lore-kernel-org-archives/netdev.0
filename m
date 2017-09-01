From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 0/2] Fix and enhance link_gre6
Date: Fri, 1 Sep 2017 22:42:26 +0200
Message-ID: <20170901204226.GZ20614@orbyte.nwl.cc>
References: <20170901140809.13230-1-phil@nwl.cc>
 <20170901121333.700624f6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38205 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752416AbdIAUm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 16:42:27 -0400
Content-Disposition: inline
In-Reply-To: <20170901121333.700624f6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Fri, Sep 01, 2017 at 12:13:33PM -0700, Stephen Hemminger wrote:
> On Fri,  1 Sep 2017 16:08:07 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Changing a tunnel's flowlabel value was broken if it was set to a
> > non-zero value before. Since the same problem existed for tclass, patch
> > 1 fixes both instances at once.
> > 
> > Patch 2 enhances 'ip link show' to also print the tclass value. This
> > change was necessary to properly test the first patch's result.
> > 
> > Phil Sutter (2):
> >   link_gre6: Fix for changing tclass/flowlabel
> >   link_gre6: Print the tunnel's tclass setting
> > 
> >  ip/link_gre6.c | 11 ++++++++++-
> >  1 file changed, 10 insertions(+), 1 deletion(-)
> > 
> 
> This doesn't work with net-next where json has been added.
> I fixing it now

Oh, thanks for that. I'm not used to having different states in master
and net-next. :)

Cheers, Phil
