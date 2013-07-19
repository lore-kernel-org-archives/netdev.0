From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RFC: configurable tcp timewait timeout sysctl kernel knob ?
Date: Fri, 19 Jul 2013 19:42:31 +0200
Message-ID: <20130719174231.GF9494@order.stressinduktion.org>
References: <CAK3+h2xK0UpkGofhqK3nsvR-3MLk81TxrWfpSiM6GbAgPRhrqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:56189 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757578Ab3GSRmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 13:42:33 -0400
Content-Disposition: inline
In-Reply-To: <CAK3+h2xK0UpkGofhqK3nsvR-3MLk81TxrWfpSiM6GbAgPRhrqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 19, 2013 at 08:59:54AM -0700, Vincent Li wrote:
> there is sysctl tcp_fin_timeout to tune FIN_WAIT2 timeout, I couldn't
> find a sysctl to tune TIME_WAIT timeout and it is hard coded to 60
> seconds, we have a situation we need to either reduce the timewait
> timeout value or recycle the timewait socket that is to use
> tcp_tw_recycle and tcp_tw_reuse, is a sysctl to tune timewait value
> good idea or bad idea that no one bothered to write one?
> 
> I have  a dirty hack patch to do that, but I think it may be  broken
> to screw something I couldn't think of.

This topic pops up from time to time. Until now David Miller (rightfully)
rejected such a patch: <http://thread.gmane.org/gmane.linux.network/244411/>

Greetings,

  Hannes
