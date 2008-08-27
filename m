From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 18:23:19 +0400
Message-ID: <20080827142319.GA4676@2ka.mipt.ru>
References: <200808220457.40892.denys@visp.net.lb> <200808271509.18529.denys@visp.net.lb> <20080827123635.GA25321@2ka.mipt.ru> <200808271700.36029.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55522 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbYH0OXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 10:23:43 -0400
Content-Disposition: inline
In-Reply-To: <200808271700.36029.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 05:00:35PM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> > > 0.0.0.0:*                          3207/udhcpd
> >
> > This one looks suspicious                                                  
> >      ^^^^^^^^^^
> It is busybox udhcpd... i guess it is innocent. Even i kill it - it doesn't 
> change anything at all. 
> Only who possible listen multicast socket - it is ripd, i cannot kill him. But 
> i think it doesn't matter much too...

It depends... If it turns timestamps on, then you will have this
behaviour. Please check if timestamps are actually enabled, so we could
remove one (im)possible case.

-- 
	Evgeniy Polyakov
