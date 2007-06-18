From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6 0/3] Deprecate IPv6 Routing Header Type 0.
Date: Mon, 18 Jun 2007 15:02:00 +0900 (JST)
Message-ID: <20070618.150200.19276134.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40386 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbXFRGBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 02:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I think the IETF community is reaching consensus on deprecation of
RH0 (Routing Header Type 0).  RH0 is now handled as unknown RH type,
e.g, accept it if segleft == 0, or send ICMPv6 Parameter Problem to
the sender.

[PATCH 1/3] [IPV6]: Restore semantics of Routing Header processing.
[PATCH 2/3] [IPV6]: Do not send RH0 anymore.
[PATCH 3/3] [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
