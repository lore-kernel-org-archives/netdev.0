From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: ndo_get_stats and rtnl_netlink
Date: Mon, 10 Sep 2012 22:10:36 +0300
Message-ID: <CAJZOPZKKca6Yea=E9reL+x-cfvX0HwsgLAWKzjonmGwutH0MxA@mail.gmail.com>
References: <504CB464.6010207@mellanox.com>
	<1347268189.1234.1301.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shlomo Pongartz <shlomop@mellanox.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39563 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097Ab2IJTKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:10:37 -0400
Received: by iahk25 with SMTP id k25so2061885iah.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 12:10:37 -0700 (PDT)
In-Reply-To: <1347268189.1234.1301.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 10, 2012 at 12:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> RTNL locking is not needed to fetch stats, and would be overkill.
> Each driver has its own way to protect/gather its stats.

FWIW, again, when dev_get_stats is called from rtnl_fill_ifinfo e.g as
of invocation
of "ip link show <interface>, there IS RTNL locking, is that a problem?

Or.
