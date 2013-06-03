From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panics in tcp_ack
Date: Mon, 03 Jun 2013 08:58:17 -0700
Message-ID: <1370275097.24311.158.camel@edumazet-glaptop>
References: <51ABE067.2050507@gmail.com>
	  <1370219787.24311.113.camel@edumazet-glaptop> <51ABFE10.1030206@gmail.com>
	  <51AC9499.8070207@gmail.com> <1370265931.24311.138.camel@edumazet-glaptop>
	 <51ACBB86.6010702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:61535 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767Ab3FCP6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:58:20 -0400
Received: by mail-pb0-f53.google.com with SMTP id un4so5855135pbc.26
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 08:58:20 -0700 (PDT)
In-Reply-To: <51ACBB86.6010702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 10:51 -0500, Rob Herring wrote:

> Any ideas on what could cause that? Anything the driver could be doing
> or not doing to cause it? Perhaps some memory ordering or visibility issue.
> 

Yes, maybe, but I have no idea.

> > Your best bet would be to perform a (reverse) bisection if you know
> > recent kernels are OK.
> 
> I did that once looking at 3.6 and 3.7 stable kernels, but they did not
> have fixes like "tcp: fix skb_availroom()" and so I just hit other
> failures. I'll do it again with more fixes applied.

Yes, you'll have to apply a number of known fixes at every step of the
bisection, sorry !
