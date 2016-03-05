From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 10:18:02 +0300
Message-ID: <20160305071802.GL4184@uranus.lan>
References: <20160304213920.GJ4184@uranus.lan>
 <20160304.175032.1728003538386465719.davem@davemloft.net>
 <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33207 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbcCEHSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 02:18:08 -0500
Received: by mail-lb0-f178.google.com with SMTP id k15so83643844lbg.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 23:18:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160304.231109.1838919633640757059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 11:11:09PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 04 Mar 2016 16:08:30 -0800
> 
> > __inet_del_ifa() should probably take into account in_dev->dead (no
> > promotion, no list scan...)
> 
> Indeed, that is the real problem:

Oh, this email dropped into my inbox a way later then
I wrote the reply. I'll test it, thanks David and Eric!
