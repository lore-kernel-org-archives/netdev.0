From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] tcp: restrict net.ipv4.tcp_adv_min_scale (#20312)
Date: Sun, 14 Nov 2010 22:14:58 +0200
Message-ID: <20101114201458.GA28181@core2.telecom.by>
References: <20101114151825.GA25137@core2.telecom.by>
 <1289764183.2743.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f194.google.com ([209.85.215.194]:42268 "EHLO
	mail-ey0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab0KNU3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 15:29:06 -0500
Received: by eya28 with SMTP id 28so791717eya.1
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 12:29:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1289764183.2743.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 14, 2010 at 08:49:43PM +0100, Eric Dumazet wrote:
> > +static int _minus_31 = -31;
> > +static int _31 = 31;
> 
> Please use normal symbols, not starting by underscore.

static int thirty_one = 31? :-)
