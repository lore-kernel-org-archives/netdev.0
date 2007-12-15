From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/4] [UDP]: memory accounting and limitation (take 10)
Date: Sat, 15 Dec 2007 00:07:44 -0500
Message-ID: <47636120.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com, Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714AbXLOFL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 00:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is the latest patch set of UDP memory accounting and limitation.

To reduce number of atomic access to global variable, the patch set
supports per socket accounting using sk_forward_alloc like stream
protocols.

My colleagues and I tested the patch set on net-2.6 tree.

Please consider applying.


Changelog take 9 -> take 10:
 * supported using sk_forward_alloc
 * introduced several memory accounting functions with spin lock
 * changed detagram receive functions to be able to customize
   destructor
 * fixed accounting bugs in previous takes

Changelog take 8 -> take 9:
 * introduced mem_schdeule functions for datargram protocols
 * removed protocol check function, from patch set
 * restructured patch set

Changelog take 7 -> take 8:

 * sk_datagram_pages(): avoided using divide instruction
 * udp_recvmsg(): fixed referring released truesize in accounting

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
