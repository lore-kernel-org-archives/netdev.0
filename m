From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to
 allocate driver local data structures
Date: Fri, 29 Oct 2004 13:02:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418277B7.7000705@pobox.com>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408> <20041029130817.GA12301@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>,
        William Lee Irwin III <wli@holomorphy.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041029130817.GA12301@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Fri, Oct 29, 2004 at 05:50:45AM -0700, Venkatesan, Ganesh wrote:
> 
>>This is a trade-off between space allocated via kmalloc and vmalloc. My
>>understanding is that kmalloc space is more limited than vmalloc. Is
>>this incorrect?
> 
> 
> Yes. kmalloc space is only limited by the amount of free memory you have
> in your system, vmalloc has very low absolute limits (down to 64MB in
> some configurations)..

However, kmalloc() has much lower per-call limits than vmalloc().

I'm interested to see a VM person weigh in on this...

Drivers are certainly allowed to use vmalloc.

	Jeff
