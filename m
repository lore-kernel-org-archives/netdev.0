From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Thu, 03 Jul 2008 17:03:04 -0400
Message-ID: <486D3E88.9090900@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <486CC440.9030909@garzik.org>	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>	 <486CCFED.7010308@garzik.org>	 <1215091999.10393.556.camel@pmac.infradead.org>	 <486CD654.4020605@garzik.org>	 <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>, Hugh Dickins <hugh@veritas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56096 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbYGCVDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 17:03:37 -0400
In-Reply-To: <1215111362.10393.651.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> Although it does make me wonder if it was better the way I had it
> originally, with individual options like TIGON3_FIRMWARE_IN_KERNEL
> attached to each driver, rather than a single FIRMWARE_IN_KERNEL option
> which controls them all.

IMO, individual options would be better.

Plus, unless I am misunderstanding, the firmware is getting built into 
the kernel image not the tg3 module?

If that is the case, then that creates problems by not moving with the 
driver.

If that is not the case, all good.

	Jeff


