From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 02:21:31 +0300
Message-ID: <b6fcc0a0811131521h69419b4an102a0cee98841a83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:42099 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbYKMXVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 18:21:33 -0500
Received: by ey-out-2122.google.com with SMTP id 6so487177eyi.37
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 15:21:31 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Something is wrong with read_pnet() as nobody suggested to mass use it
> > or send a patch doing it.
>
> I did. My plan is to zap all superflous #ifdef CONFIG_NET_NS if possible.

That's not mass usage.

Mass usage is, say, s/dev_net/read_pnet/.

Do you want to do this too?

> How do you want to implement a C function that can write to ib->ib_net ?

I've sent ib_net_set().

> Take the time to read the patch, please.

You too.
