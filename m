From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH,RFC] [NET] ALIGN
Date: Mon, 9 Feb 2004 11:20:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209112007.08023ba6.davem@redhat.com>
References: <20040209.134528.28683257.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040209.134528.28683257.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 09 Feb 2004 13:45:28 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> D: Use ALIGN() where appricable.
> 
> BTW, 
>  1. do we really need this ALIGN?
>  2. should 16 be BYTES_PER_WORD (in mm/slab.c)?

Let's hold on this patch.

Why does it want to align the table entry size to 16 bytes
anyways?

I think this is complete nonsense, and that the alignment is not
necessary.  I can't even come up with a performance reason as SLAB
is going to align things to hw cache line size anyways.

Can anybody come up with some theory ? :-)

Else let's just remove this bogus 16 byte alignment in the
kmem_cache_create() call.
