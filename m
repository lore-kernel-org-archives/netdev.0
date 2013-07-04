From: Pierre Emeriaud <petrus.lt@gmail.com>
Subject: Re: PROBLEM: Linux 3.9 more-specific ipv6 route ignored until
 next-hop is in neighbor cache
Date: Thu, 4 Jul 2013 07:20:37 +0200
Message-ID: <CA+PSOpziMTBD-dNbjtYO+EcvoMuO0NBw7V-0OHCtAAzZQEG4Uw@mail.gmail.com>
References: <20130703181546.GC12615@order.stressinduktion.org>
	<51D46B9F.6050400@cogentembedded.com>
	<20130703184504.GD12615@order.stressinduktion.org>
	<20130703.175153.1664868495830722209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hannes@stressinduktion.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:56775 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab3GDFUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 01:20:38 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so1158712obc.34
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 22:20:37 -0700 (PDT)
In-Reply-To: <20130703.175153.1664868495830722209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/7/4 David Miller <davem@davemloft.net>:
>>
>> [PATCH net v2] ipv6: rt6_check_neigh should successfully verify neigh if no NUD information are available
>
> Applied and queued up for -stable, thanks everyone.

I just tested the patch and it works fine! The more-specific route is
now preferred over default even if the next-hop is not (yet) known in
the neighbor cache.

Thanks everyone !

-pierre.
