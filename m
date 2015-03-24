From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v2] man ip-netns: Fix syntax in default ns
 process, indent's
Date: Tue, 24 Mar 2015 10:29:24 +0200
Message-ID: <20150324082924.GA1276@angus-think.wlc.globallogic.com>
References: <1426960318-12044-1-git-send-email-vadim4j@gmail.com>
 <20150323011120.GA20755@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org,
	ben@decadent.org.uk
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33404 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbbCXIlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 04:41:18 -0400
Received: by labto5 with SMTP id to5so46017998lab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 01:41:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150323011120.GA20755@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:11:24AM +0900, Simon Horman wrote:
> On Sat, Mar 21, 2015 at 07:51:58PM +0200, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> > v2:
> >     Deleted leading spaces - suggested by Ben Hutchings <ben@decadent.org.uk>
> > 
> >  man/man8/ip-netns.8 | 18 +++++++++++++-----
> >  1 file changed, 13 insertions(+), 5 deletions(-)
> > 
> > diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
> > index d496675..0c3dca8 100644
> > --- a/man/man8/ip-netns.8
> > +++ b/man/man8/ip-netns.8
> > @@ -46,7 +46,7 @@ ip-netns \- process network namespace management
> >  A network namespace is logically another copy of the network stack,
> >  with its own routes, firewall rules, and network devices.
> >  
> > -By default process inherits network namespace from its parent. Initially all
> > +By default a process inherits network namespace from its parent. Initially all
> 
> Perhaps also s/inherits/inherits its/
> 
> >  the processes share the same default network namespace from the init process.
> >  
> >  By convention a named network namespace is an object at
> > @@ -103,10 +103,18 @@ option was specified then all the network namespace names will be removed.
> >  It is possible to lose the physical device when it was moved to netns and
> >  then this netns was deleted with a running process:
> >  
> > -    $ ip netns add net0
> > -    $ ip link set dev eth0 netns net0
> > -    $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> > -    $ ip netns del net0
> > +.RS 10
> > +$ ip netns add net0
> > +.RE
> > +.RS 10
> > +$ ip link set dev eth0 netns net0
> > +.RE
> > +.RS 10
> > +$ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> > +.RE
> > +.RS 10
> > +$ ip netns del net0
> > +.RE
> >  
> >  and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
> >  will exit or will be killed. To prevent this the processes running in net0
> > -- 
> > 2.3.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 

Hi,

So may it be like this ?

	By default a process inherits its network namespace from the parent.

or like this ?

	By default a process inherits its network namespace from its parent.

Thanks,
