From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] Export accept queue len of a TCP listening socket
	via	/proc/net/tcp{6}
Date: Wed, 21 Jun 2006 17:35:09 -0700
Message-ID: <1150936509.2868.30.camel@w-sridhar2.beaverton.ibm.com>
References: <E1FtCws-0005in-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:23703 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932147AbWFVAgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 20:36:02 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5M0a0UZ007486
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 20:36:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5M0a0m6260902
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 20:36:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5M0ZxiS027495
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 20:36:00 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FtCws-0005in-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 10:21 +1000, Herbert Xu wrote:
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> > 
> > In order to support this with netstat/ss that use netlink mechanism to
> > get the socket info, i think we need to extend tcp_info to add this field.
> > Can this be done in a backward compatible way?
> 
> What about using the same fields (rqueue/wqueue) as you did for /proc?

I meant extending tcp_info structure to add new fields. I think the user
space also uses this structure.

Thanks
Sridhar

