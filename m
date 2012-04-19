From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/6] TCP connection repair (v4)
Date: Thu, 19 Apr 2012 17:38:58 +0400
Message-ID: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39610 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211Ab2DSNjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Attempt #4 with an API for TCP connection recreation (previous one is
at http://lists.openwall.net/netdev/2012/03/28/84) re-based on the
today's net-next tree.


Changes since v3:

* Added repair for TCP options negotiated during 3WHS process, pointed
  out by Li Yu. The explanation of how this happens is in patch #6.

* Named constant for sk_reuse values as proposed by Ben Hutching.

* Off-by-one in repair-queue sockoption caught by Ben.

Thanks,
Pavel
