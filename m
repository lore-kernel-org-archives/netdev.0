From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: remove support for per driver
 ndo_busy_poll()
Date: Fri, 03 Feb 2017 15:07:01 -0800
Message-ID: <1486163221.21871.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203.171820.956894207079399896.davem@davemloft.net>
         <20170203.172853.2189881865706510657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34243 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752401AbdBCXHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:07:03 -0500
Received: by mail-pg0-f66.google.com with SMTP id v184so3073953pgv.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:07:03 -0800 (PST)
In-Reply-To: <20170203.172853.2189881865706510657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 17:28 -0500, David Miller wrote:

> Actually, one more driver needs converting, "enic".
> 
> I did a quick and dirty conversion:
> 
> ====================
> From 7a655c6324a8968ea2f027bf3660c87c42ac3de4 Mon Sep 17 00:00:00 2001
> From: "David S. Miller" <davem@davemloft.net>
> Date: Fri, 3 Feb 2017 17:28:21 -0500
> Subject: [PATCH] enic: Remove local ndo_busy_poll() implementation.
> 
> We do polling generically these days.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Oh sorry about that. Looks fine, thanks a lot !
