From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Wed, 17 Sep 2003 16:06:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309171559540.3831-100000@localhost.localdomain>
References: <20030912164628.GF8713@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>,
        <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030912164628.GF8713@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003, Arnaldo Carvalho de Melo wrote:

> Latest 2.6 bk tree, but I think this is hanging there for quite a while.
> 
> CC [M]  net/sctp/sm_make_chunk.o
> {standard input}: Assembler messages:
> {standard input}:2386: Error: Field not properly aligned [8] (52).
> {standard input}:2386: Error: Invalid operands
> {standard input}:2398: Error: Field not properly aligned [8] (52).
> {standard input}:2398: Error: Invalid operands
> make[2]: *** [net/sctp/sm_make_chunk.o] Error 1
> make[1]: *** [net/sctp] Error 2
> make: *** [net] Error 2
> 
> it happens in the sctp_pack_cookie function.

I don't see this problem on i386, ia64 or ppc64. Can someone familiar with parisc64
provide more details or submit a a patch to fix this problem?

Thanks
Sridhar
