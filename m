From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, rb_insert_color, HTB, ifb
Date: Wed, 25 Jun 2008 20:14:08 +0200
Message-ID: <48628AF0.4030907@gmail.com>
References: <200806250900.10152.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:51107 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbYFYSLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 14:11:06 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2655540wri.5
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 11:11:03 -0700 (PDT)
In-Reply-To: <200806250900.10152.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 06/25/2008 08:00 AM:

> Kernel is vanilla, with HTB hysteresis changed to 0 (i guess in this git it is not patched like that by default).
> Version 2.6.26-rc6-git2
> 
> This bug very rare and happening on router only sometimes, once per 3-4 days, but it is hitting the router and sometimes crashing it critically.
> Not always NMI watchdog can reboot it, and on this chipset iTCO_wdt not functional :-(
> I was hunting for this panic message last 1-2 month.
> 


Hi Denys,

I think, you could try with CONFIG_DEBUG_OBJECTS_TIMERS (unless it's on already).

Regards,
Jarek P.
