From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: Limit mtu to 65572 bytes
Date: Fri, 11 Apr 2014 11:30:44 +0900
Message-ID: <534753D4.6070600@linux-ipv6.org>
References: <5345A2B3.7040602@gmail.com>	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140409223546.GH27255@order.stressinduktion.org>	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140410235459.GK27255@order.stressinduktion.org>	 <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com> <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58097 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754365AbaDKCas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 22:30:48 -0400
In-Reply-To: <1397180530.16584.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> We must limit the IPv6 MTU to (65535 + 40) bytes in theory.
> 
> In practice, its better to align to a multiple of 4 for optimal TCP
> performance.

It is a TCP issue.  We should not limit the mtu to 65532+40.
I am for 65535+40. Otherwise, other protocol such as UDP cannot
use full mtu as before.

--yoshfuji
