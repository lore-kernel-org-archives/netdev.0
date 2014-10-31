From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: DMA allocations from CMA and fatal_signal_pending check
Date: Fri, 31 Oct 2014 22:07:10 +0100
Message-ID: <1414789630.14835.49.camel@sakura.staff.proxad.net>
References: <544FE9BE.6040503@gmail.com>
	 <20141031082818.GB14642@js1304-P5Q-DELUXE>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, lauraa@codeaurora.org,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 linux-kernel@vger.kernel.org, mina86@mina86.com,  linux-mm@kvack.org,
 aneesh.kumar@linux.vnet.ibm.com, Gregory Fong <gregory.0xf0@gmail.com>,
 gioh.kim@lge.com, akpm@linux-foundation.org, Brian Norris
 <computersforpeace@gmail.com>, linux-arm-kernel@lists.infradead.org,
 m.szyprowski@samsung.com
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20141031082818.GB14642@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


On Fri, 2014-10-31 at 17:28 +0900, Joonsoo Kim wrote:

> I guess that it is okay that bcm_sysport_open() return -EINTR?

actually, since CMA alloc is hidden behind dma_alloc_coherent(), all you
get back is NULL and then return ENOMEM.

-- 
Maxime


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
