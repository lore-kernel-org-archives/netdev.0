From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 14:08:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029130817.GA12301@infradead.org>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, jgarzik@pobox.com,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 05:50:45AM -0700, Venkatesan, Ganesh wrote:
> This is a trade-off between space allocated via kmalloc and vmalloc. My
> understanding is that kmalloc space is more limited than vmalloc. Is
> this incorrect?

Yes. kmalloc space is only limited by the amount of free memory you have
in your system, vmalloc has very low absolute limits (down to 64MB in
some configurations)..

> With the original implementation that used kmalloc for all allocations
> in the driver, I have noticed allocation failures when the ring sizes
> were set to 4096.

4096 what?
