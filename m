From: "Ananda Raju" <Ananda.Raju@neterion.com>
Subject: RE: [1/4] [IPV6]: Remove redundant length check on input
Date: Fri, 30 Jun 2006 19:44:49 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4C8@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:25060 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S932573AbWF3XpD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:45:03 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id D68F52014A8A
	for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 19:45:02 -0400 (EDT)
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 

I tested the patch, and TSO over ipv6 is working fine. But TSO disable
not working for IPv6. 

I tried the from tree /pub/scm/linux/kernel/git/davem/net-2.6

Ananda 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, June 30, 2006 2:20 PM
To: herbert@gondor.apana.org.au
Cc: Ananda Raju; netdev@vger.kernel.org
Subject: Re: [1/4] [IPV6]: Remove redundant length check on input

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jun 2006 15:42:09 +1000

> I've added GSO for TCPv6 and updated Ananda's patch.  Please note that
> the following patches have only been compile-tested.

I applied this and pushed it to Linus, let's cross our fingers :)

