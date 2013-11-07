From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 08:13:40 -0800
Message-ID: <1383840820.9412.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	 <15059450.XJdZrMIbNO@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56173 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab3KGQNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 11:13:42 -0500
Received: by mail-pb0-f54.google.com with SMTP id ro12so812053pbb.27
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 08:13:42 -0800 (PST)
In-Reply-To: <15059450.XJdZrMIbNO@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 15:49 +0200, Sergey Popovich wrote:


> commit 64153ce0a7b61b2a5cacb01805cbf670142339e9
> Author: Eric Dumazet
> Date:   Thu Jun 6 14:53:16 2013 -0700
> 
>     net_sched: htb: do not setup default rate estimators
> 
> rate estimators do not setup by default. To enable rate estimators
> you could try to load module sch_htb with htb_rate_est=1 
> or echo 1 >/sys/module/sch_htb/parameters/htb_rate_est and recreate
> hierarchy.
> 

To check if packets went through a class, you do not need
a rate estimator. Its 0 anyway after an idle period.

You have to take a look at counters as in :

Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
