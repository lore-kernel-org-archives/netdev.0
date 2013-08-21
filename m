From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V2] ipv6: handle Redirect ICMP Message with no Redirected Header option
Date: Wed, 21 Aug 2013 05:04:27 +0200
Message-ID: <20130821030427.GD20223@order.stressinduktion.org>
References: <52131725.6000409@cn.fujitsu.com> <20130820115020.GB3938@order.stressinduktion.org> <52142209.6030406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36032 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab3HUDE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 23:04:29 -0400
Content-Disposition: inline
In-Reply-To: <52142209.6030406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 21, 2013 at 10:12:25AM +0800, Duan Jiong wrote:
> > Introducing a new function here is the right thing. Maybe you could have
> > a look how these redirects could be fed to raw sockets, too?
> > 
> Because of no Redirected Header option, so we don't have enough
> information to find out the related raw socket. So, there is no need
> to deal with that condition.

Ah, of course. I thought we could look up the socket solely by src and
dst address. I forgot about the protocol.
