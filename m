From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] IPV6 address management
Date: Thu, 8 Jan 2009 09:34:30 -0800
Message-ID: <20090108093430.0f966738@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51775 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755836AbZAHRee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 12:34:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I notice that with IPV6 when interface is brought down, all addresses
are removed. This looks like intentional behaviour but means the
administrator (or daemon) must reinsert addresses. Since this is not
what the users expect it does lead to confusion.

Maybe the kernel should do this?
