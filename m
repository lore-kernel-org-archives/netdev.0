From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: linux-next: manual merge of the limits tree with the net and
 fsnotify trees
Date: Fri, 04 Dec 2009 08:59:22 +0100
Message-ID: <4B18C15A.8060901@gmail.com>
References: <20091204183011.e92d36cd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Paris <eparis@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091204183011.e92d36cd.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2009 08:30 AM, Stephen Rothwell wrote:
> diff --cc arch/x86/ia32/ia32entry.S
> index da89ae1,c61ced2..0000000
> --- a/arch/x86/ia32/ia32entry.S
> +++ b/arch/x86/ia32/ia32entry.S
> @@@ -841,7 -841,6 +841,9 @@@ ia32_sys_call_table
>   	.quad compat_sys_pwritev
>   	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
>   	.quad sys_perf_event_open
>  +	.quad compat_sys_recvmmsg
>  +	.quad sys_fanotify_init
>  +	.quad sys32_fanotify_mark
> + 	.quad compat_sys_getprlimit

Thanks, but please go on with the by-five numbering in comments.

> + 	.quad compat_sys_setprlimit
>   ia32_syscall_end:
...
> diff --cc arch/x86/kernel/syscall_table_32.S
> index ca486c7,2dd45cd..0000000
> --- a/arch/x86/kernel/syscall_table_32.S
> +++ b/arch/x86/kernel/syscall_table_32.S
> @@@ -336,6 -336,5 +336,8 @@@ ENTRY(sys_call_table
>   	.long sys_pwritev
>   	.long sys_rt_tgsigqueueinfo	/* 335 */
>   	.long sys_perf_event_open
>  +	.long sys_recvmmsg
>  +	.long sys_fanotify_init
>  +	.long sys_fanotify_mark
> + 	.long sys_getprlimit

And here too.

> + 	.long sys_setprlimit


-- 
js
