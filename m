From: Kelly Daly <kelly@au1.ibm.com>
Subject: Re: [PATCH] Netchannel: default, find, add to socket
Date: Tue, 11 Jul 2006 16:14:55 +1000
Message-ID: <200607111614.56028.kelly@au.ibm.com>
References: <200607111539.25458.kelly@au.ibm.com> <20060711055708.GA3935@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Kelly Daly <kelly@au1.ibm.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:26562 "EHLO
	ausmtp05.au.ibm.com") by vger.kernel.org with ESMTP id S965168AbWGKGP3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 02:15:29 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.6/8.13.6) with ESMTP id k6B6IAYx8290536
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 16:18:10 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k6B6IegN204144
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 16:18:40 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6B6Dtgs011670
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 16:13:56 +1000
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060711055708.GA3935@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 11 July 2006 03:57 pm, Evgeniy Polyakov wrote:
> You have a typo in the code commented below.

D'oh!!!  That one completely slipped by me - thanks!

I'll resend this patch =)

> I have a question regarsing your netchannel design - as far as I can
> see, you steal data in interrupts and then convert it into skb and run
> through usual netif_receive_skb(). Thus you dedicate one thread (one
> CPU) to do the whole processing for all sockets which do not have
> netchannels bound to them. Did you benchmarked such approach both with
> and without netchannel bound to the socket?

No benchmarking as of yet...  Have been a bit busy of late with something 
else, but getting back into this V shortly and will hopefully have a whole 
lot more info for you soon.


Cheers,
K
