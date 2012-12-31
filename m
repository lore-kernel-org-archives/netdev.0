From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Tue, 1 Jan 2013 00:48:27 +0100
Message-ID: <20121231234827.GC11700@order.stressinduktion.org>
References: <20121231173532.GA11700@order.stressinduktion.org> <20121231140412.7dee9821@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57903 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab2LaXs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 18:48:28 -0500
Content-Disposition: inline
In-Reply-To: <20121231140412.7dee9821@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2012 at 02:04:12PM -0800, Stephen Hemminger wrote:
> On Mon, 31 Dec 2012 18:35:33 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 182ca99..aa3c30e 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -944,6 +944,7 @@ struct proto {
> >  	int			*sysctl_rmem;
> >  	int			max_header;
> >  	bool			no_autobind;
> > +	int			ecn;
> >  
> Why isn't this a bool?

It is a tristate: disable ecn(0), request ecn(1) and accept ecn(2).
