From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/5] lib: cpu_rmap: CPU affinity
 reverse-mapping
Date: Mon, 24 Jan 2011 15:01:40 -0800 (PST)
Message-ID: <20110124.150140.39171549.davem@davemloft.net>
References: <1295470787.11126.82.camel@bwh-desktop>
	<1295471005.11126.86.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295471005.11126.86.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Jan 2011 21:03:25 +0000

> When initiating I/O on a multiqueue and multi-IRQ device, we may want
> to select a queue for which the response will be handled on the same
> or a nearby CPU.  This requires a reverse-map of IRQ affinity.  Add
> library functions to support a generic reverse-mapping from CPUs to
> objects with affinity and the specific case where the objects are
> IRQs.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
