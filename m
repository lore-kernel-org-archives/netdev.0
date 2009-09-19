From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [iproute2 PATCH] Add 'ip tuntap' support.
Date: Sat, 19 Sep 2009 12:55:29 -0700
Message-ID: <1253390129.6317.31.camel@macbook.infradead.org>
References: <1253378923.6317.11.camel@macbook.infradead.org>
	 <20090919125222.5f4718f1@s6510>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55029 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbZISTze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2009 15:55:34 -0400
In-Reply-To: <20090919125222.5f4718f1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-09-19 at 12:52 -0700, Stephen Hemminger wrote:
> 
> I added it, but:
>   * cleaned up whitespace

Thanks.

>   * use if_tun.h from sanitized 2.6.30

Hm, what's the difference, other than the lack of IFF_TUN_EXCL?

>   * ifdef IFF_TUN_EXCL flag, so can build with older code
>    (currently iproute is releasing for 2.6.30)

IFF_TUN_EXCL is harmless (ignored) on older kernels -- when I looked at
compatibility I decided to just set it anyway. Sorry, perhaps I should
have mentioned that in the commit comment... but I'd completely
forgotten about it.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

