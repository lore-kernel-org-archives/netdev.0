From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Sun, 30 Dec 2007 03:47:33 -0500
Message-ID: <47775B25.7020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>,
	Hideo AOKI <haoki@redhat.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	vladislav.yasevich@hp.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbXL3I71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 03:59:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch set introduces new memory accounting interface.
Current interface is written for stream protocols only.
To enable memory accounting in other protocols (e.g. UDP),
I enhanced the interface and updated TCP and SCTP memory
accounting.

The patch set consists of the following 4 patches.

[1/4] introducing new memory accounting interface
[2/4] adding memory accounting points to consolidate functions
[3/4] updating TCP to use new interface
[4/4] updating SCTP to use new interface

The patch set was tested on net-2.6.25 tree.

Best regards,
Hideo Aoki

--
Hitachi Computer Products (America) Inc.
