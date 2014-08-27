From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 Policy based routing not working.
Date: Wed, 27 Aug 2014 16:19:09 +0200
Message-ID: <1409149149.26515.28.camel@localhost>
References: <CABQpAL7X9_=RTS2cd_m3jkCzWOM8hjcu22yQdnRD6S4fs5AF2Q@mail.gmail.com>
	 <1409090482.1152.8.camel@localhost>
	 <CABQpAL4J7D704iw8Qj9SNDxW8E1P7Mw+KONUapZY6_LdoHkEYw@mail.gmail.com>
	 <1409118957.11976.9.camel@localhost>
	 <CABQpAL4zbeqX4X1Kuzw-+FOppmYx7VzTzJn9OMLyYVBdS0Bz9w@mail.gmail.com>
	 <1409119546.11976.11.camel@localhost>
	 <CABQpAL4tpfAXNbk7AgqV-FZKSSAMVYN_jvOkj58Sc719xKxB-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tushar Shinde <mtk.tushar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60067 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934785AbaH0OTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 10:19:13 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 6A7EF20728
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:19:12 -0400 (EDT)
In-Reply-To: <CABQpAL4tpfAXNbk7AgqV-FZKSSAMVYN_jvOkj58Sc719xKxB-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-08-27 at 19:11 +0530, Tushar Shinde wrote:
> ping6 command uses SO_BINDTODEVICE but it looks it is not working. The
> source address in fib6 rule match is 0:::0
> 
> strace ping6 -I eth0 2001:2::20 2> t
> socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 4
> setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, "eth0\0", 5) = 0
> connect(4, {sa_family=AF_INET6, sin6_port=htons(1025),
> inet_pton(AF_INET6, "2001:2::20", &sin6_addr), sin6_flowinfo=0,
> sin6_scope_id=0}, 28) = -1 ENETUNREACH (Network is unreachable)

$ strace ping6 -c1 -I em1 ::  |& grep SO_BINDTODEVICE
$

Strange, I have a look... thanks!
