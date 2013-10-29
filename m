From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 09:37:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
References: <20131027164835.GB4714@order.stressinduktion.org><20131028.171725.1076499130782328273.davem@davemloft.net><20131028233158.GA26185@order.stressinduktion.org> <20131028.204306.2213130677400093266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <jiri@resnulli.us>, <vyasevich@gmail.com>,
	<netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<thaller@redhat.com>, <stephen@networkplumber.org>
To: "David Miller" <davem@davemloft.net>, <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55336 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751310Ab3J2JjF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:39:05 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21051-07 for <netdev@vger.kernel.org>;
 Tue, 29 Oct 2013 09:39:01 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131028.204306.2213130677400093266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Note that you don't even need to put the DHCP protocol core into the
> kernel to fix the promiscuous problem.  You just have to use the
> current kernel interfaces correctly.
> 
> It used to be the case a very long time ago that you couldn't even
> receive broadcast UDP datagrams on a socket until an address was
> configured on it.
> 
> So everyone turns on promiscuous mode and uses RAW sockets or
> AF_PACKET.
> 
> Stupid?  yes.

Not only that, but the dhcp client could use a normal UDP socket
to keep the lease renewed - I suspect it has only ever needed
to use the BPF interface (I didn't think it set promiscuous)
when acquiring the initial lease.

	David
 
