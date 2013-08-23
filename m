From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: expose IPV4_DEVCONF
Date: Thu, 22 Aug 2013 20:30:36 -0700 (PDT)
Message-ID: <20130822.203036.1163035239116579220.davem@davemloft.net>
References: <20130821210947.3ef36570@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, tgraf@infradead.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab3HWDah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 23:30:37 -0400
In-Reply-To: <20130821210947.3ef36570@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 21 Aug 2013 21:09:47 -0700

> IP sends device configuration (see inet_fill_link_af) as an array
> in the netlink information, but the indices in that array are not
> exposed to userspace through any current santized header file.
> 
> It was available back in 2.6.32 (in /usr/include/linux/sysctl.h)
> but was broken by:
>   commit 02291680ffba92e5b5865bc0c5e7d1f3056b80ec
>   Author: Eric W. Biederman <ebiederm@xmission.com>
>   Date:   Sun Feb 14 03:25:51 2010 +0000
> 
>     net ipv4: Decouple ipv4 interface parameters from binary sysctl numbers
>     
> Eric was solving the sysctl problem but then the indices were re-exposed
> by a later addition of devconf support for IPV4
> 
>   commit 9f0f7272ac9506f4c8c05cc597b7e376b0b9f3e4
>   Author: Thomas Graf <tgraf@infradead.org>
>   Date:   Tue Nov 16 04:32:48 2010 +0000
> 
>     ipv4: AF_INET link address family
> 
> Putting them in /usr/include/linux/ip.h seemed the logical match
> for the DEVCONF_ definitions for IPV6 in /usr/include/linux/ip6.h
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Looks good, applied, thanks Stephen.
