From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: drop fragmented ndisc packets by default (RFC 6980)
Date: Tue, 27 Aug 2013 05:48:33 +0200
Message-ID: <20130827034833.GA31971@order.stressinduktion.org>
References: <20130826233651.GA9183@order.stressinduktion.org> <CAOp4FwRWze=HG-8bp8R5nicC0b=R1ZRc6e6+fseXvn==gLqn0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	Fernando Gont <fernando@gont.com.ar>, yoshfuji@linux-ipv6.org
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48167 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab3H0Dse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 23:48:34 -0400
Content-Disposition: inline
In-Reply-To: <CAOp4FwRWze=HG-8bp8R5nicC0b=R1ZRc6e6+fseXvn==gLqn0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 07:40:21AM +0400, Loganaden Velvindron wrote:
> On Tue, Aug 27, 2013 at 3:36 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > This patch implements RFC6980: Drop fragmented ndisc packets by
> > default. If a fragmented ndisc packet is received the user is informed
> > that it is possible to disable the check.
> >
> 
> It's similar to the older patch except that now it's under a sysctl ?

Yes, logic is the same + warning message + can be disabled via sysctl.

Greetings,

  Hannes
