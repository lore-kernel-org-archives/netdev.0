From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Mon, 04 Feb 2013 07:21:07 -0800
Message-ID: <1359991267.30177.143.camel@edumazet-glaptop>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	 <20121013163639.87abca00.bircoph@gmail.com>
	 <1350135860.21172.14606.camel@edumazet-glaptop>
	 <20121014031119.a60263d6.bircoph@gmail.com>
	 <20121021032543.09d1844f.bircoph@gmail.com>
	 <1350823941.13333.2167.camel@edumazet-glaptop>
	 <20121022073636.98462bc6.bircoph@gmail.com>
	 <1350888489.8609.322.camel@edumazet-glaptop>
	 <20121023012759.ca7f91d6.bircoph@gmail.com>
	 <20121212122716.1e71f644.bircoph@gmail.com>
	 <20121223150627.d7ebcf6a.bircoph@gmail.com>
	 <1356718263.21409.430.camel@edumazet-glaptop>
	 <20130116203644.8eb2a16f.bircoph@gmail.com>
	 <20130204173932.bad780bc.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49240 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab3BDPVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 10:21:10 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so2440173pad.38
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 07:21:09 -0800 (PST)
In-Reply-To: <20130204173932.bad780bc.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 17:39 +0400, Andrew Savchenko wrote:

> With 16-days uptime system works fine.
> 
> Also I was able to reproduce this bug on another box: an embedded
> system running openwrt with 3.7.5 kernel with openl2tpd client and
> dnsmasq server. Due to limited memory resources this bug happened to
> be easily reproducible: several thousands of dns queries were
> sufficient to reproduce this bug. Full debug on embedded box was not
> possible due to constrained resources, but bug appearance was the same
> and /proc/net/udp is apparently broken (see attached log).
> 
> I applied your patch on openwrt's 3.7.5 kernel and it fixed the bug
> on this box too.
> 
> So we've found a solution and I'm looking forward for it in the main
> kernel :)

Thanks a lot for testing, I'll send the official patch asap.
