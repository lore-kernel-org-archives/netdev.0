From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to
 allocate driver local data structures
Date: Fri, 29 Oct 2004 14:26:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41828B5D.7090908@pobox.com>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408> <20041029130817.GA12301@infradead.org> <418277B7.7000705@pobox.com> <20041029173636.GB12934@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: William Lee Irwin III <wli@holomorphy.com>
In-Reply-To: <20041029173636.GB12934@holomorphy.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

William Lee Irwin III wrote:
> vmalloc is relatively highly penalized. For instance, global TLB
> flushes associated with vfree() and so on. Aggregate vmallocspace
> limitations are a big concern. I probably wouldn't use vmallocspace
> for much besides infrequent allocations, e.g. things allocated during
> driver initialization. One per driver instance won't really hurt much
> because vmallocspace limits prevent large numbers of drivers from being
> simultaneously loaded as it stands now anyway.


That's precisely what we're contemplating -- a once per driver 
allocation that remains static for the entire driver runtime (descriptors)

	Jeff
