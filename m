From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 1/2] ip: fix "ip -6 route add ... nexthop"
Date: Thu, 25 Oct 2012 09:08:15 -0700
Message-ID: <20121025090815.5b7925ac@nehalam.linuxnetplumber.net>
References: <20121023.023910.80461258323920266.davem@davemloft.net>
	<1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, bernat@luffy.cx,
	eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50166 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755057Ab2JYQJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 12:09:04 -0400
In-Reply-To: <1350996176-4000-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Oct 2012 14:42:55 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> From: Vincent Bernat <bernat@luffy.cx>
> 
> IPv6 multipath routes were not accepted by "ip route" because an IPv4
> address was expected for each gateway. Use `get_addr()` instead of
> `get_addr32()`.
> 
> Signed-off-by: Vincent Bernat <bernat@luffy.cx>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Looks good. Applied.
