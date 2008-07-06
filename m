From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sun, 06 Jul 2008 16:51:13 -0400
Message-ID: <48713041.7000900@garzik.org>
References: <1215178035.10393.763.camel@pmac.infradead.org>	 <486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>	 <20080704.134329.209642254.davem@davemloft.net>	 <20080704220444.011e7e61@lxorguk.ukuu.org.uk>	 <alpine.DEB.1.10.0807061311030.11010@asgard.lang.hm> <1215376034.3189.127.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david@lang.hm, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57126 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757191AbYGFUv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 16:51:57 -0400
In-Reply-To: <1215376034.3189.127.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Sun, 2008-07-06 at 13:17 -0700, david@lang.hm wrote:
>> if David W were to make it possible to not use the load_firmware() call to 
>> userspace and build the firmware into the driver (be it in a monolithic 
>> kernel or the module that contains the driver)
> 
> You _can_ build the firmware into the kernel.

Which is a problem for those rare situations, like oh say vendor 
kernels, where you can ship a driver update but not update the main kernel.

Just like with modules, we were all given the _choice_ to use the new 
regime (modules) or stick with the old (100% monolithic kernel).

Under any new system, firmware should be able to be compiled into the 
driver module itself -- as it is today.

	Jeff



