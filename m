From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 21:44:59 +0300
Message-ID: <20160305184459.GO4184@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160305155714.GM4184@uranus.lan>
 <20160305.113312.1758700509401944239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:36392 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbcCESpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 13:45:09 -0500
Received: by mail-lb0-f172.google.com with SMTP id x1so93203284lbj.3
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 10:45:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160305.113312.1758700509401944239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2016 at 11:33:12AM -0500, David Miller wrote:
...
> 
> Probably the same optimization can be applied there, see patch below.
> And if that doesn't do it, there is a really easy way to batch the
> delete by scanning the FIB tree in one go and deleting every entry
> that points to "in_dev".  But I suspect we really won't need that.

It made it to work faster but still for 10000 addresses it takes
~3-4 minutes to become alive again.

David, give me some time, I'll prepare tests and report the
results on patches and unpatched versions. And thanks a huge
for both patches!

	Cyrill
