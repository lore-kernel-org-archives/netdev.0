From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 09:36:37 -0400
Message-ID: <1275485797.3545.4.camel@bigi>
References: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	 <1275481219.14363.6.camel@bigi> <1275481538.14363.10.camel@bigi>
	 <20100602.054520.228955151.davem@davemloft.net>
	 <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38415 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab0FBNgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:36:44 -0400
Received: by pwj2 with SMTP id 2so1685805pwj.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:36:43 -0700 (PDT)
In-Reply-To: <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 21:14 +0800, Changli Gao wrote:


> Maybe skb_header_pointer() is lighter.

A little worse than skb_copy_bits(). In any case, this change is going
to hurt.
Dave, can we assume the upper layers(qdiscs in this case) are
responsible for any linearizing?

Changli, if you have time - can you also audit tcf_pedit()
since it follows TheLinuxWay(tm).

cheers,
jamal

