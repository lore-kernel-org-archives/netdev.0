From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/10] Refactor netdev page frags and move them into mm/
Date: Mon, 11 May 2015 13:36:52 -0700
Message-ID: <20150511133652.cd885d654213fe4161da0d87@linux-foundation.org>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150510.191758.2130017622255857830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150510.191758.2130017622255857830.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sun, 10 May 2015 19:17:58 -0400 (EDT) David Miller <davem@davemloft.net> wrote:

> > 4.9%	build_skb		3.8%	__napi_alloc_skb
> > 2.5%	__alloc_rx_skb
> > 1.9%	__napi_alloc_skb
> 
> I like this series, but again I need to see feedback from some
> mm folks before I can consider applying it.

The MM part looks OK to me - it's largely moving code out of net/ into
mm/.  It's a bit weird and it's unclear whether the code will gain
other callers, but putting it in mm/ increase the likelihood that some other
subsystem will use it.

Please merge it via a net tree when ready.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
