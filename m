From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] use local_softirq_pending instead of softirq_pending in
 netif_rx_ni
Date: Thu, 18 Nov 2004 14:22:44 -0800
Message-ID: <20041118142244.0de3378a.davem@davemloft.net>
References: <20041114103846.GA32024@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041114103846.GA32024@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Nov 2004 11:38:46 +0100
Christoph Hellwig <hch@lst.de> wrote:

> Some architectures can optimize local_softirq_pending much better than
> softirq_pending(smp_processor_id()), and for all others the former is
> just a macro expanding to the later.
> 
> Also this is the last use of softirq_pending() in common code, once this
> is in we can soon kill the notation of beeing able to query other cpus
> softirq pending count.

Queued for 2.6.11, thanks Christoph.
