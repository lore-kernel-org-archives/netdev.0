From: Andrew Morton <akpm@osdl.org>
Subject: Re: Oops at "NET: Registering protocol family 23" at boot with
 2.6.0t9-bk
Date: Sat, 1 Nov 2003 13:36:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101133601.7cf12497.akpm@osdl.org>
References: <1067705386.666.1.camel@chevrolet.hybel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stian Jordet <liste@jordet.nu>
In-Reply-To: <1067705386.666.1.camel@chevrolet.hybel>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stian Jordet <liste@jordet.nu> wrote:
>
> Hello,
> kernel 2.6.0-test9 works perfect here, but with the latest cset I get
> the attached oops at boottime. Hope this helps someone.
> 

Please send your .config.

> NET: Registered protocol family 23
> Unable to handle kernel NULL pointer dereference at virtual address 00000004
>  printing eip:
> c03de40d
> *pde = 00000000
> Oops: 0002 [#1]
> CPU:    0
> CIP:    0060:[<c03de40d>]    Not tainted
> EFLAGS: 00010202
> EIP is at dev_add_pack+0x4d/0xb0
> eax: 00000038   ebx: c062f2f8   ecx: 00000000   edx: c05799e0
> esi: c05799d0   edi: 00000000   ebp: 00000000   esp: c152ffb4
> ds: 007b   es: 007b   ss: 0068
> Process swapper (pid: 1, threadinfo=c152e000 task=dff8f900)
> Stack: c05e7fc8 00000001 c05defad c05799d0 c04af833 c05c094c 00000000 00000000
>        c01359af 00000000 c152e000 c01050f6 00000002 c01050a0 00000000 c01072b9
>        00000000 00000000 00000000
> Call Trace:
>  [<c05defad>] irda_init+0x3d/0x60
>  [<c05c094c>] do_initcalls+0x2c/0xa0
>  [<c01359af>] init_workqueues+0xf/0x24
>  [<c01050f6>] init+0x56/0x180
>  [<c01050a0>] init+0x0/0x180
>  [<c01072b9>] kernel_thread_helper+0x5/0xc
>  
> Code: 89 51 04 89 90 c0 f2 62 c0 c6 05 40 3c 57 c0 01 b8 00 e0 ff
>  (0)Kernel panic: Fatal exception in interrupt
> In interrupt handler - not syncing
>      
> 
> 
