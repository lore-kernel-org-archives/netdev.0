From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] Install the bridge command under the same name
 we build it.
Date: Mon, 13 Aug 2012 08:04:21 -0700
Message-ID: <20120813080421.3a4593a1@nehalam.linuxnetplumber.net>
References: <87ehnmiv1m.fsf@spindle.srvr.nix>
	<501F2311.8070708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nick Alcock <nick.alcock@oracle.com>, netdev@vger.kernel.org
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49036 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785Ab2HMPEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:04:36 -0400
In-Reply-To: <501F2311.8070708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Aug 2012 09:51:13 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> On 08/04/2012 10:36 PM, Nick Alcock wrote:
> > 
> > Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> > ---
> >  bridge/Makefile | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/bridge/Makefile b/bridge/Makefile
> > index 0c333bf..9a6743e 100644
> > --- a/bridge/Makefile
> > +++ b/bridge/Makefile
> > @@ -7,8 +7,8 @@ all: bridge
> >  bridge: $(BROBJ) $(LIBNETLINK) 
> >  
> >  install: all
> > -	install -m 0755 br $(DESTDIR)$(SBINDIR)
> > +	install -m 0755 bridge $(DESTDIR)$(SBINDIR)
> >  
> >  clean:
> > -	rm -f $(BROBJ) br
> > +	rm -f $(BROBJ) bridge
> >  
> 
> Hi Nick,
> 
> To post a patch for iproute2, you should send it to 
> Stephen Hemminger <shemminger@vyatta.com> who is the maintainer of iproute2.
> 
> 
> Stephen, I also noticed this problem and thought should ask you for the final
> name of the brige extension. Personally I prefer br, it is short and
> distingushable enough.
> 
> Thanks.

br was already taken by X10 package on debian.
