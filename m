From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 08:54:30 -0400
Message-ID: <1282136070.23601.26.camel@bigi>
References: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
	 <1282129364.23601.17.camel@bigi>
	 <AANLkTi=50qHT_-OoMbWcPT1Fi7JEa0e_kReZhnpVJJdR@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:49133 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab0HRMyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 08:54:37 -0400
Received: by qwh6 with SMTP id 6so464249qwh.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 05:54:37 -0700 (PDT)
In-Reply-To: <AANLkTi=50qHT_-OoMbWcPT1Fi7JEa0e_kReZhnpVJJdR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 20:42 +0800, Changli Gao wrote:

> I suppose we want to spread the traffic as possible as we can. For
> ESP, we use the SPI as a key. And I think we can also use SPI in the
> AH header as a key. It does change the semantic slightly for AH, but I
> should not hurt, as the only effect is that the AH traffic is
> distributed into different flows according to their different SPI.

Sounds sensible - but please go through the code and double check that
nothing breaks (since i dont think you tested and i sympathize it would
be very time consuming to test) and more importantly when you make such
fundamental changes at least make comments to that effect in the logs.

cheers,
jamal

