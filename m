From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp_cubic: add SNMP counters to track how
 effective is Hystart
Date: Thu, 04 Dec 2014 17:10:05 -0800
Message-ID: <1417741805.22424.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141205001754.GG16959@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Sangtae Ha <sangtae.ha@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:58733 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820AbaLEBKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 20:10:07 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so17005541iec.38
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 17:10:07 -0800 (PST)
In-Reply-To: <20141205001754.GG16959@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 01:17 +0100, Florian Westphal wrote:

> Alternatively we could add INET_DIAG_CUBICINFO and export such info via ss
> tool.

Thats a complete different model.

When studying some param changes on servers handling million of flows,
SNMP hosts stats are giving the picture, without having to collect huge
ss info in the background and aggregating it.
