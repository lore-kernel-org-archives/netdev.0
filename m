From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Mon, 20 Dec 2010 14:31:28 +0800
Message-ID: <4D0EF840.2020108@cn.fujitsu.com>
References: <616589.97517.qm@web29017.mail.ird.yahoo.com>	<4CF75BC3.1020606@cn.fujitsu.com> <20101216.121805.59690737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: albertpretorius@yahoo.co.uk, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54532 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753245Ab0LTGd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 01:33:28 -0500
In-Reply-To: <20101216.121805.59690737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, at 12/17/2010 04:18 AM:
> Your approach will only modify socket based route handling, it will
> not handle the ipv6 forwarding case which as per the quoted RFC
> sections must be handled too.

For the ipv6 forwarding case, we have done the check in ip6_forward().

 493                 int addrtype = ipv6_addr_type(&hdr->saddr);
 494 
 495                 /* This check is security critical. */
 496                 if (addrtype == IPV6_ADDR_ANY ||
 497                     addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
 498                         goto error;


-- 
Best Regards
-----
Shan Wei
