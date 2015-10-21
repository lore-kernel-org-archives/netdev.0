From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH 9/9] treewide: Remove newlines inside DEFINE_PER_CPU()
 macros
Date: Wed, 21 Oct 2015 15:27:55 -0400
Message-ID: <5627E73B.9000502@redhat.com>
References: <1444940195-28272-1-git-send-email-mmarek@suse.com> <1444940195-28272-10-git-send-email-mmarek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: Michal Marek <mmarek@suse.com>, linux-kbuild@vger.kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <1444940195-28272-10-git-send-email-mmarek@suse.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/2015 04:16 PM, Michal Marek wrote:
> Otherwise make tags can't parse them:
> 
> ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
> ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
> ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
> ctags: Warning: kernel/locking/lockdep.c:153: null expansion of name pattern "\1"
> ctags: Warning: kernel/workqueue.c:305: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
> ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
> ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
> ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
> ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
> 
> Cc: linux-ia64@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> Cc: linux-acpi@vger.kernel.org
> Cc: rds-devel@oss.oracle.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Marek <mmarek@suse.com>
> ---
>  arch/ia64/kernel/smp.c         | 3 +--
>  drivers/acpi/processor_idle.c  | 3 +--
>  drivers/xen/events/events_2l.c | 3 +--
>  kernel/locking/lockdep.c       | 3 +--
>  kernel/rcu/rcutorture.c        | 6 ++----
>  kernel/workqueue.c             | 3 +--
>  net/ipv4/syncookies.c          | 3 +--
>  net/ipv6/syncookies.c          | 3 +--
>  net/rds/page.c                 | 3 +--
>  9 files changed, 10 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
> index 7f706d4f84f7..1dcfe29d8a42 100644
> --- a/arch/ia64/kernel/smp.c
> +++ b/arch/ia64/kernel/smp.c
> @@ -57,8 +57,7 @@ static struct local_tlb_flush_counts {
>  	unsigned int count;
>  } __attribute__((__aligned__(32))) local_tlb_flush_counts[NR_CPUS];
>  
> -static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned short [NR_CPUS],
> -				     shadow_flush_counts);
> +static DEFINE_PER_CPU_SHARED_ALIGNED(unsigned short [NR_CPUS], shadow_flush_counts);
>  

I guarantee you're going to end up fixing this issue over and over again as more
code is added in.

OOC, why not fix ctags to recognize newlines?

P.

