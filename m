From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] ipv6: Limit mtu to 65575 bytes
Date: Fri, 11 Apr 2014 08:26:43 -0700
Message-ID: <1397230003.16584.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <534753D4.6070600@linux-ipv6.org>
	 <1397186427.16584.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1397190216.16584.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140411132207.GO27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:49634 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbaDKP0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 11:26:45 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so5371084pdj.6
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 08:26:45 -0700 (PDT)
In-Reply-To: <20140411132207.GO27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-11 at 15:22 +0200, Hannes Frederic Sowa wrote:

> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Eric, the optimization for limiting the mtu in tcp case is still possible.
> It is not that people don't care. ;)

I am not sure I want to add an additional test in TCP, as current
systems do not really have performance issues. I would 99.99% of the
time, MSS is already a multiple of 4.

I think we have more pressing problems ;)
