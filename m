From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.17-mm3
Date: Fri, 7 Jul 2006 19:22:27 -0700
Message-ID: <20060707192227.1d95ca0e@localhost.localdomain>
References: <20060627015211.ce480da6.akpm@osdl.org>
	<6bffcb0e0606270712w166f04a6u237d695e2bfa1913@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Arjan van de Ven" <arjan@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33237 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932486AbWGHCWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 22:22:45 -0400
To: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
In-Reply-To: <6bffcb0e0606270712w166f04a6u237d695e2bfa1913@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2006 16:12:42 +0200
"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com> wrote:

> Hi,
> 
> On 27/06/06, Andrew Morton <akpm@osdl.org> wrote:
> >
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17/2.6.17-mm3/
> >
> >
> 
> It looks like a skge bug
> 
> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> ---------------------------------------------------------
> swapper/0 just changed the state of lock:
>  (tasklist_lock){..-?}, at: [<c0128092>] send_group_sig_info+0x16/0x34
> but this lock took another, soft-irq-unsafe lock in the past:
>   (&sig->stats_lock){--..}
> 
> and interrupts could create inverse lock ordering between them.
> 
> 
> other info that might help us debug this:
> no locks held by swapper/0.
> 
> the first lock's dependencies:
> -> (tasklist_lock){..-?} ops: 13763 {
>    initial-use  at:
>                         [<c01353ab>] lock_acquire+0x60/0x80
>                         [<c02d0ce2>] _write_lock_irq+0x29/0x38
>                         [<c011c4e3>] copy_process+0xea7/0x13c0
>                         [<c011cc6a>] do_fork+0x8d/0x18f
>                         [<c010136c>] kernel_thread+0x6c/0x74
>                         [<c0100518>] rest_init+0x14/0x3c
>                         [<c03b6769>] start_kernel+0x388/0x390
>                         [<c0100210>] 0xc0100210
>    in-softirq-R at:
> [..]
> 
> Here is a dmesg log http://www.stardust.webpages.pl/files/mm/2.6.17-mm3/mm-dmesg


That file no longer exists...

> Here is a config file
> http://www.stardust.webpages.pl/files/mm/2.6.17-mm3/mm-config
> 
> Regards,
> Michal
> 


-- 
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Richlieu
