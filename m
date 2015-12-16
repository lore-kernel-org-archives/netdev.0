From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Random packet loss using IPsec with AES128-SHA1
Date: Wed, 16 Dec 2015 10:59:54 +0100
Message-ID: <20151216095954.GN29565@gauss.secunet.com>
References: <000a01d137e2$afedd130$0fc97390$@drvsource.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Gabriele Beltrame <belgab@drvsource.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39892 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932907AbbLPJ75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 04:59:57 -0500
Content-Disposition: inline
In-Reply-To: <000a01d137e2$afedd130$0fc97390$@drvsource.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 10:17:54AM +0100, Gabriele Beltrame wrote:
> Hi,
> 
> I'm running a few Strongswan 5.3.* CentOS (Kernel 3.16.7, 4.2.6, 4.1.*)
> instances on AWS to terminate VPNs between each other and/or to other
> devices across the Internet.
> While investigating some application issues, I've noticed that on every VPNs
> I have random packet losses (from 1% to 4% over 100 to 300 requests sent).
> This only happens when the two following conditions are met: (a) AES
> encryption used, (b) IP packet size shorter than about (150+8+20)Bytes.

I've never seen this.

If xfrm statistics are compiled in, a counter is bumped for each packet
dropped by IPsec. You can check these counters in /proc/net/xfrm_stat.

This will tell you at least whether IPsec is the reason for your packet
loss.
