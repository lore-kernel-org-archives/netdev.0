From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/3] Report socket shutdown state via sock-diag
Date: Tue, 23 Oct 2012 20:18:51 +0400
Message-ID: <5086C36B.6060508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36343 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421Ab2JWQTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 12:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk->sk_shutdown mask (set by sys_shutdown) cannot be read from
the user space. I suppose that the best API to report it is the
recently added sock-diag one (as we can use it not only in the
checkpoint-restore project, but also enhance the ss output with the
shutdown info).

However, there's one issue with the inet-diag part of it -- we've
run out of bits on the extension flags of dump request. This one is
addressed in the patch #2.

Thanks,
Pavel
