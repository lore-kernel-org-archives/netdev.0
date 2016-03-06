From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sun, 06 Mar 2016 08:23:12 -0800
Message-ID: <1457281392.2663.5.camel@edumazet-ThinkPad-T530>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
	 <20160304.231109.1838919633640757059.davem@davemloft.net>
	 <20160306100932.GP4184@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	solar@openwall.com, vvs@virtuozzo.com, avagin@virtuozzo.com,
	xemul@virtuozzo.com, vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36069 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbcCFQXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 11:23:15 -0500
Received: by mail-pa0-f41.google.com with SMTP id tt10so1871879pab.3
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 08:23:15 -0800 (PST)
In-Reply-To: <20160306100932.GP4184@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On dim., 2016-03-06 at 13:09 +0300, Cyrill Gorcunov wrote:

> Anyway, then I run this script for 255 as parameter
> in one pass which gen. requests to create 65025 addresses
> and kernel start complaining:
> 
> Perf output
> -----------
>   24.95%  [kernel]                      [k] __local_bh_enable_ip
>   21.52%  [kernel]                      [k] lock_acquire
>   15.54%  [kernel]                      [k] lock_release
>    9.84%  [kernel]                      [k] lock_is_held
>    7.47%  [kernel]                      [k] lock_acquired
>    4.08%  [kernel]                      [k] __local_bh_disable_ip

Well, this looks like LOCKDEP kernel. Are you really running LOCKDEP on
production kernels ?
