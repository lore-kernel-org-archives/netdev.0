From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] RxRPC: Rewrite part 1
Date: Fri, 04 Mar 2016 17:20:10 -0500 (EST)
Message-ID: <20160304.172010.571829527806753588.davem@davemloft.net>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 04 Mar 2016 16:37:05 +0000

> Here's the first set of patches from my RxRPC rewrite, aimed at net-next.
> These do some clean ups and bug fixes.  Most of the changes are small, but
> there are a couple of bigger changes:
> 
>  (*) Convert call flag numbers and event numbers into enums.  Then rename
>      the event numbers to all have _EV_ in their name to stop confusion.
>      Fix one instance of an event bit being used instead of a flag bit.
> 
>  (*) A copy of the Rx protocol header is kept in the sk_buff private data.
>      Keep this in host byte order rather than network byte order as it
>      makes more sense.  A number of other fields then get converted into
>      host byte order too.
> 
>      Conversion between host and network byte order is then done at the
>      packet reception/generation stage.
> 
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160304
> 
> This is based on net-next/master

This looks really nice, pulled, thanks a lot David.

Can you go through and use "unsigned int" instead of just plain
"unsigned" in the RxRPC code?

Thanks.
