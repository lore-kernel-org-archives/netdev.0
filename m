From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12 2.4] e1000 - use vmalloc for data structures not shared with h/w
Date: Thu, 29 Jul 2004 19:25:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729192519.A6235@infradead.org>
References: <468F3FDA28AA87429AD807992E22D07E01F23824@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E01F23824@orsmsx408>; from ganesh.venkatesan@intel.com on Thu, Jul 29, 2004 at 11:17:08AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 29, 2004 at 11:17:08AM -0700, Venkatesan, Ganesh wrote:
> Vmalloc space is less scarce than kmalloc space. Am I right? This patch
> trades kmalloc space for vmalloc space.

No, it's not.  vmalloc needs virtual space that's rather limited (e.g. 64MB
on PAE x86) in addition to physical memory.  Unless you do really big
allocations stay away from vmalloc.
