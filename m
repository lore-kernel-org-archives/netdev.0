From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 09:47:06 -0400
Message-ID: <1275486426.3545.6.camel@bigi>
References: <20100602.054520.228955151.davem@davemloft.net>
	 <AANLkTil0sLvcHRTcGTfYYlCYzDH07sl7xgk6EcjL99cl@mail.gmail.com>
	 <1275485797.3545.4.camel@bigi>
	 <20100602.064316.218079399.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45829 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab0FBNrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:47:12 -0400
Received: by pwj2 with SMTP id 2so1691314pwj.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 06:47:11 -0700 (PDT)
In-Reply-To: <20100602.064316.218079399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 06:43 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>

> > 
> > A little worse than skb_copy_bits(). In any case, this change is going
> > to hurt.
> 
> Umm, Jamal what are you talking about?

;->

> Using skb_header_pointer(), if the offset is in range, there is no
> change from today other than a comparison.

Thats the part i glossed over - My eyes just saw "it calls
skb_copy_bits()" ;->

> If it is not in range, we use skb_copy_bits().  It's only for the
> case where we have to fetch the value from the fragmented part
> of the SKB.

cheers,
jamal

