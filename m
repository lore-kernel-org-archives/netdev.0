From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] man ip-netns: Fix syntax in default ns process,
 indent's
Date: Sat, 21 Mar 2015 13:46:41 +0200
Message-ID: <20150321114641.GA31471@angus-think.lan>
References: <1426915962-17112-1-git-send-email-vadim4j@gmail.com>
 <1426935263.32382.33.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:36482 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbCUL63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 07:58:29 -0400
Received: by wibg7 with SMTP id g7so8942974wib.1
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 04:58:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426935263.32382.33.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 10:54:23AM +0000, Ben Hutchings wrote:
> On Sat, 2015-03-21 at 07:32 +0200, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> >  man/man8/ip-netns.8 | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
> > index d496675..fe885db 100644
> > --- a/man/man8/ip-netns.8
> > +++ b/man/man8/ip-netns.8
> > @@ -46,7 +46,7 @@ ip-netns \- process network namespace management
> >  A network namespace is logically another copy of the network stack,
> >  with its own routes, firewall rules, and network devices.
> >  
> > -By default process inherits network namespace from its parent. Initially all
> > +By default a process inherits network namespace from its parent. Initially all
> >  the processes share the same default network namespace from the init process.
> >  
> >  By convention a named network namespace is an object at
> > @@ -103,10 +103,12 @@ option was specified then all the network namespace names will be removed.
> >  It is possible to lose the physical device when it was moved to netns and
> >  then this netns was deleted with a running process:
> >  
> > +.RS
> >      $ ip netns add net0
> >      $ ip link set dev eth0 netns net0
> >      $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
> >      $ ip netns del net0
> > +.RE
> 
> You should delete the leading spaces as well.
> 
> Ben.
> 
> >  and eth0 will appear in the default netns only after SOME_PROCESS_IN_BACKGROUND
> >  will exit or will be killed. To prevent this the processes running in net0
> 
> -- 
> Ben Hutchings
> If you seem to know what you are doing, you'll be given more to do.

Hi,

Would it be OK?

.RS 10
$ ip netns add net0
.RE
.RS 10
$ ip link set dev eth0 netns net0
.RE
.RS 10
$ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
.RE
.RS 10
$ ip netns del net0
.RE

Thanks,
