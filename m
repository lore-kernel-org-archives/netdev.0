From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 2 Jun 2010 21:43:14 +0800
Message-ID: <AANLkTilZt3mfYt1hcDUc4VpNT5NEYoiGrFVjpGPAZH7q@mail.gmail.com>
References: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	<1275481219.14363.6.camel@bigi> <1275481538.14363.10.camel@bigi>
	<20100602.054520.228955151.davem@davemloft.net> <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
	<1275485797.3545.4.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51085 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758084Ab0FBNnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:43:37 -0400
Received: by pvg16 with SMTP id 16so62465pvg.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:43:34 -0700 (PDT)
In-Reply-To: <1275485797.3545.4.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 2, 2010 at 9:36 PM, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2010-06-02 at 21:14 +0800, Changli Gao wrote:
>
>
>> Maybe skb_header_pointer() is lighter.
>
> A little worse than skb_copy_bits(). In any case, this change is going
> to hurt.

Why? it is an inline function, and in most cases, there isn't any function call.

> Dave, can we assume the upper layers(qdiscs in this case) are
> responsible for any linearizing?
>
> Changli, if you have time - can you also audit tcf_pedit()
> since it follows TheLinuxWay(tm).
>

Yea, pedit has the same issue. Besides this issue, they should use
get_unaligned() instead.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
