From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: 2.6: rxrpc compile errors with SYSCTL=n
Date: Thu, 12 Aug 2004 00:56:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811225634.GR26174@fs.tum.de>
References: <20040811223225.GN26174@fs.tum.de> <20040811224102.GU11200@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: William Lee Irwin III <wli@holomorphy.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040811224102.GU11200@holomorphy.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 11, 2004 at 03:41:02PM -0700, William Lee Irwin III wrote:
> On Thu, Aug 12, 2004 at 12:32:25AM +0200, Adrian Bunk wrote:
> > I'm getting tons of the following compile errors in 2.6.8-rc4-mm1 (but 
> > it doesn't seem to be specific to -mm) with CONFIG_SYSCTL=n:
> > <--  snip  -->
> > ...
> >   LD      .tmp_vmlinux1
> > net/built-in.o(.text+0x154127): In function `__rxrpc_call_acks_timeout':
> > : undefined reference to `rxrpc_kdebug'
> > net/built-in.o(.text+0x154167): In function `__rxrpc_call_rcv_timeout':
> > : undefined reference to `rxrpc_kdebug'
> 
> Does this help?
>...

Yes.

Thanks for the quick patch!

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
