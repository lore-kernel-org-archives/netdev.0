From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] net: Work around lockdep limitation in sockets
 that use sockets
Date: Thu, 09 Mar 2017 09:38:51 -0800 (PST)
Message-ID: <20170309.093851.1057108507009455288.davem@davemloft.net>
References: <20170308.230625.719131946756053988.davem@davemloft.net>
        <148881267372.2618.822975702493802450.stgit@warthog.procyon.org.uk>
        <21773.1489045894@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21773.1489045894@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 09 Mar 2017 07:51:34 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> I guess this is fine, but I think you can use one of the two "sk_padding"
>> bits in struct sock instead of making the structure larger.
> 
> It shouldn't make the structure larger since there's a hole in the structure:
 ...
> 		u16			sk_gso_max_segs;
>   ---> 2-byte hole here
> 		unsigned long	        sk_lingertime;
> 
> but I'll quite happily shift it to sk_padding.

Ok, then that's fine.
