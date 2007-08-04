From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Sat, 4 Aug 2007 20:49:10 +0400
Message-ID: <20070804164910.GD14175@2ka.mipt.ru>
References: <20070802184840.GA8901@2ka.mipt.ru> <20070802.192134.107254907.davem@davemloft.net> <20070803082242.GA25582@2ka.mipt.ru> <20070803.130451.63127177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51277 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932109AbXHDQtu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2007 12:49:50 -0400
Content-Disposition: inline
In-Reply-To: <20070803.130451.63127177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 01:04:51PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 3 Aug 2007 12:22:42 +0400
> 
> > On Thu, Aug 02, 2007 at 07:21:34PM -0700, David Miller (davem@davemloft.net) wrote:
> > > What in the world are we doing allowing stream sockets to autobind?
> > > That is totally bogus.  Even if we autobind, that won't make a connect
> > > happen.
> > 
> > For accepted socket it is perfectly valid assumption - we could autobind 
> > it during the first send. Or may bind it during accept. Its a matter of
> > taste I think. Autobinding during first sending can end up being a 
> > protection against DoS in some obscure rare case...
> 
> accept()ed socket is by definition fully bound and already in
> established state.

That what I meant - it binds during accept (well it can not be called
real binding), but could be autobound during first send to needed port.
Maybe that was one of intentions, don't know.

-- 
	Evgeniy Polyakov
