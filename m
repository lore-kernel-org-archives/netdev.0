From: David Miller <davem@davemloft.net>
Subject: Re: udp hash change and ipv6
Date: Mon, 30 Apr 2007 22:33:51 -0700 (PDT)
Message-ID: <20070430.223351.95061522.davem@davemloft.net>
References: <20070501.130717.115545945.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030965AbXEAFdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 01:33:53 -0400
In-Reply-To: <20070501.130717.115545945.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 01 May 2007 13:07:17 +0900 (JST)

> Because I do not have enough time before depature to Lima
> via LAX, I cannot send a full fix for this, but anyway...
> 
> In net-2.6, __udp_lib_get_port() touches inet_sk(sk)->rcv_saddr,
> which will break ipv6, I think.  We probably need to add a
> extra function pointer to check is sk has wildcard rcv_saddr
> for the protocol.
> 
> static udp4_is_rcvaddr_any(const struct sock *sk)
> {
>     return (!inet_sk(sk)->rcv_saddr);
> }
> 
> static udp6_is_rcvaddr_any(const struct sock *sk)
> {
>     return (ipv6_addr_any(inet_sk(sk)->rcv_saddr));
> }
> 
> Or something.  We may need to think about ipv6only socket
> option.

I am aware of these issues and will take care of them.
