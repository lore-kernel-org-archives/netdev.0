From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: Oops in register_proc_table (2.6.1-mm4)
Date: Fri, 16 Jan 2004 18:21:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116182154.0b45a072.akpm@osdl.org>
References: <20040116104709.2163912c.akpm@osdl.org>
	<20040116112310.424d9020.akpm@osdl.org>
	<200401170040.52852.thomas.schlichter@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Schlichter <thomas.schlichter@web.de>
In-Reply-To: <200401170040.52852.thomas.schlichter@web.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Schlichter <thomas.schlichter@web.de> wrote:
>
> Am Freitag, 16. Januar 2004 20:23 schrieb Andrew Morton:
> > Andrew Morton <akpm@osdl.org> wrote:
> > > NET: Registered protocol family 10
> > > Unable to handle kernel paging request at virtual address 000927c0
> > >  printing eip:
> > > c012ba17
> > > *pde = 00000000
> > > Oops: 0000 [#1]
> > > PREEMPT
> > > CPU:    0
> > > EIP:    0060:[<c012ba17>]    Not tainted VLI
> > > EFLAGS: 00010246
> > > EIP is at register_proc_table+0x47/0x120
> > > eax: 00000000   ebx: e106c9ec   ecx: ffffffff   edx: 000927c0
> > > esi: 00000000   edi: 000927c0   ebp: c012b130   esp: de4ddd7c
> > > ds: 007b   es: 007b   ss: 0068
> > > Process modprobe (pid: 1936, threadinfo=de4dc000 task=de9e3900)
> > > Stack: e1061159 000081a4 de6e5c40 81a40000 de6e5c40 e106d480 00000000
> > > de6e5c40 00000000 c012ba7c e10617fc 0000416d de6e5cc0 416d0000 de6e5cc0
> > > e106d640 00000000 de6e5cc0 00000000 c012ba7c e1061862 0000416d dffccac0
> > > 416dddec Call Trace:
> > >  [<c012ba7c>] register_proc_table+0xac/0x120
> > >  [<c012ba7c>] register_proc_table+0xac/0x120
> > >  [<c012ba7c>] register_proc_table+0xac/0x120
> > >  [<c012bb4e>] register_sysctl_table+0x5e/0x80
> > >  [<e105d347>] ipv6_sysctl_register+0x17/0x20 [ipv6]
> > >  [<e0e9018b>] inet6_init+0x18b/0x2d0 [ipv6]
> > >  [<c013b62b>] sys_init_module+0x17b/0x1670
> > >  [<c0152cd6>] vma_link+0x76/0xc0
> > >  [<c015423c>] do_mmap_pgoff+0x38c/0x6f9
> > >  [<c015e109>] filp_close+0x59/0xa0
> > >  [<c015e1ab>] sys_close+0x5b/0xa0
> > >  [<c02df843>] syscall_call+0x7/0xb
> > >
> > > Code: 33 85 f6 0f 84 9b 00 00 00 8b 53 04 85 d2 89 d7 74 ea 8b 73 18 85
> > > f6 75 0b 8b 43 14 85 c0 0f 84 cb 00 00 00 31 c0 b9 ff ff ff ff <f2> a
> > > e f7 d1 49 85 f6 0f b7 43 10 89 cd 66 89 44 24 0e 74 6d 66
> > >  <7>request_module: failed /sbin/modprobe -- net-pf-10. error = 11
> > >
> > > If this is not enough information to track down the problem I can provide
> > > my .config of any other information, of course.
> >
> > Actually, yes.  Please send your .config.
> 
> OK, here it is... ;-)
> 

Works fine here.
