From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Fri, 28 Jul 2017 14:14:34 +0200
Message-ID: <20170728121434.vld76q7kohzpmtk2@torres.zugschlus.de>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
 <1500905950.2458.6.camel@redhat.com>
 <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
 <1501229277.2597.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:52032 "EHLO
        torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdG1MOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 08:14:35 -0400
Content-Disposition: inline
In-Reply-To: <1501229277.2597.1.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 10:07:57AM +0200, Paolo Abeni wrote:
> Ad a workaround you can disable UDP early demux:
> 
> echo 0 > /proc/sys/net/ipv4/udp_early_demux
> 
> (will affect both ipv4 and ipv6).
> 
> and (if the system  is already into the bad state) increase the udp
> accounted memory limit, writing in /proc/sys/net/ipv4/udp_mem greater
> values than the current ones (the actual values depends on the system
> total memory).

I can confirm that these two changes make a system in bad state work
again immediately. Will try the patch on 4.12.4 later today.

Thanks for helping!

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
