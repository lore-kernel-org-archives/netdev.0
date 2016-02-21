From: Rana Shahout <rana.shahot@gmail.com>
Subject: Re: Tools for sampling ethtool --statistics
Date: Sun, 21 Feb 2016 11:40:57 +0200
Message-ID: <CALYk33gHWBcQ7T_4FKxwG2x56pMK6YU+qcyTogx4pMVqGsvcmA@mail.gmail.com>
References: <20160120101311.5266cac6@redhat.com>
	<CAKHjkj=+zaYXvHQWkWuU2LLVRxT_V7Pvmd3QqoGUdOL=HDjsRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: brouer@redhat.com, netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33846 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcBUTDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 14:03:24 -0500
Received: by mail-ob0-f169.google.com with SMTP id ts10so33010167obc.1
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 11:03:24 -0800 (PST)
In-Reply-To: <CAKHjkj=+zaYXvHQWkWuU2LLVRxT_V7Pvmd3QqoGUdOL=HDjsRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi All,
>
> I wrote a small tool[1] to extract ethtool --statistics|-S, sample and
> present it in a more human readable manor.  You might also find this
> useful...
>
> https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl
>
> The reason I wrote this script is that the mlx5 driver (Mellanox 100 Gbit/s)
> does not report correct ifconfig stats.  It reports the HW counters,
> not what the network stack is able to handle.  I/we obviously need the
> stack number when working on improving the stack.

mlx5 drive does not report correct counters also in ethtool statistics
(ethtool -S).
ethtool statistics reports also the HW counters, so all counters
except counters per channel are wrong.
We are working on fix. It will be available soon.

>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>
