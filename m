From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 1371] New: kernel fails to compile with ipv6
 error
Date: Sat, 18 Oct 2003 16:08:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018160855.26fea7b8.akpm@osdl.org>
References: <200310182118.h9ILIBMX001067@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: simon@swat.me.uk
In-Reply-To: <200310182118.h9ILIBMX001067@fire-1.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bugme-daemon@osdl.org wrote:
>
> http://bugme.osdl.org/show_bug.cgi?id=1371
> 
>            Summary: kernel fails to compile with ipv6 error
>     Kernel Version: 2.6.0-test8
>             Status: NEW
>           Severity: blocking
>              Owner: bugme-janitors@lists.osdl.org
>          Submitter: simon@swat.me.uk
> 
> 
> The following error is produced when compiling the kernel:
> 
>   AR      arch/i386/lib/lib.a
>   GEN     .version
>   CHK     include/linux/compile.h
>   UPD     include/linux/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> net/built-in.o(.text+0x57987): In function `ipip6_rcv':
> : undefined reference to `__secpath_destroy'
> make: *** [.tmp_vmlinux1] Error 1
> 
> This problem did not occur with test7 or previous kernels.
> 

Odd.  Please send your .config.
