From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 14:50:59 -0800
Message-ID: <20100311145059.1a020e1c@nehalam>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	<1268337450-6749-4-git-send-email-jengelh@medozas.de>
	<20100311121239.14944fd5@nehalam>
	<20100311.122639.258785986.davem@davemloft.net>
	<20100311140406.37ee0b83@nehalam>
	<alpine.LSU.2.01.1003112305060.11569@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58407 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714Ab0CKWvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 17:51:01 -0500
In-Reply-To: <alpine.LSU.2.01.1003112305060.11569@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 23:13:18 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> On Thursday 2010-03-11 23:04, Stephen Hemminger wrote:
> >> >> `ip -s link` shows interface counters truncated to 32 bit. This is
> >> >> because interface statistics are transported only in 32-bit quantity
> >> >> to userspace. This commit adds a new IFLA_STATS64 attribute that
> >> >> exports them in full 64 bit.
> >> 
> >> On 64-bit it has 64-bit counters, yet we only report 32-bit
> >> counters to userspace via netlink even in that case.
> >
> >That make sense, but maybe we shouldn't send IFLA_STATS64 on
> >32bit platforms.
> 
> Somehow I'd prefer to have consistency. Platform-specific 
> actions and/or payload I think we already were plagued enough by 
> syscalls and iptables. (Just to name two.)

But if you send 32bit truncated values when 64 bit is expected
then users are going to complain

-- 
