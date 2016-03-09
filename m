From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 23:41:58 +0300
Message-ID: <20160309204158.GO2207@uranus.lan>
References: <20160309170921.GL2207@uranus.lan>
 <20160309.122400.951958972682394628.davem@davemloft.net>
 <20160309175307.GM2207@uranus.lan>
 <20160309.152730.691838022304871697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:33110 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcCIUmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 15:42:05 -0500
Received: by mail-lb0-f177.google.com with SMTP id k15so84159835lbg.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 12:42:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309.152730.691838022304871697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 03:27:30PM -0500, David Miller wrote:
> > 
> > Yes. I can drop it off for a while and run tests without it,
> > then turn it back and try again. Would you like to see such
> > numbers?
> 
> That would be very helpful, yes.

Just sent out. Take a look please. Indeed it sits inside get_next_corpse
a lot. And now I think I've to figure out where we can optimize it.
Continue tomorrow.
