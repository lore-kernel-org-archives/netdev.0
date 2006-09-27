From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 12:31:44 -0700
Message-ID: <20060927123144.4e343183@freekitty>
References: <20060926145113.7a6791c8@freekitty>
	<4519A1D6.1050802@pobox.com>
	<Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53199 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030679AbWI0Tcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 15:32:51 -0400
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006 12:24:59 -0700 (PDT)
dean gaudet <dean@arctic.org> wrote:

> On Tue, 26 Sep 2006, Jeff Garzik wrote:
> 
> > Stephen Hemminger wrote:
> > > The mii-tool utility seems to be abandoned and unmaintained?
> > > 
> > > Here is a version that does standard 1000baseT support.
> > > 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
> > 
> > Not really.  I would rather leave it as-is, and deprecate it in favor of
> > ethtool.
> 
> is there some ethtool (version 5) option i'm missing that will give a nice 
> concise link negotation state report like mii-tool does?
> 
> on e1000 it seems i can find this info only via the -d option, which dumps 
> a lot of other info.
> 
> on skge -d doesn't seem to dump the negotiation state.
>

Not possible because the PHY registers are accessed indirectly.

> on tg3 -d doesn't even interpret the registers...
> 
> maybe it's just that i haven't had caffeine but i think i've tried every 
> reporting option i can find on the man page and can't find link 
> negotiation state.
> 
> -dean


-- 
Stephen Hemminger <shemminger@osdl.org>
