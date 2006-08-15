From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Mon, 14 Aug 2006 22:46:05 -0400
Message-ID: <1155609965.6946.74.camel@jzny2>
References: <E1GCnEZ-0006XU-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:64158 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1752003AbWHOCqJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 22:46:09 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GCowZ-0005J1-M7
	for netdev@vger.kernel.org; Mon, 14 Aug 2006 22:46:15 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GCnEZ-0006XU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 10:56 +1000, Herbert Xu wrote:

> Agreed.  The pid field in the netlink header should be treated as an
> opaque value.  Any attempt to interpret it as the process ID is doomed
> to failure.


Not necessarily as a processid ("PID" is a really bad noun in that
sense); but rather as something meaningful of interpretation in regards
to the real origin of the executed change. 
The concept of "whodunnit" is invaluable. 
And a processid tends to be useful when nothing else is there to
identify the originator. Just saying "it is the kernel" (PID=0) when the
kernel just acted as a proxy of some user space app, is not useful all
the times, IMO.
[Routes, but not other functional blocks in rtnetlink, actually have a
field (called protocol) that says who added them]. Thats all the quagga
and other folks were looking for in cases where it was ambigous. 

cheers,
jamal

