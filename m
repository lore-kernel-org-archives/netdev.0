From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 16:32:52 -0700 (PDT)
Message-ID: <20060816.163252.64000941.davem@davemloft.net>
References: <20060816.143203.11626235.davem@davemloft.net>
	<200608170016.47072.arnd@arndb.de>
	<20060816233028.GO20551@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linuxppc-dev@ozlabs.org, akpm@osdl.org,
	jeff@garzik.org, netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12230
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751239AbWHPXcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 19:32:52 -0400
To: linas@austin.ibm.com
In-Reply-To: <20060816233028.GO20551@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Wed, 16 Aug 2006 18:30:28 -0500

> Why would you want o do this? It seems like a cruddier strategy 
> than what we can already do  (which is to never get an transmit
> interrupt, as long as the kernel can shove data into the device fast
> enough to keep the queue from going empty.)  The whole *point* of a 
> low-watermark interrupt is to never have to actually get the interrupt, 
> if the rest of the system is on its toes and is supplying data fast
> enough.

As long as TX packets get freed within a certain latency
boundary, this kind of scheme should be fine.
