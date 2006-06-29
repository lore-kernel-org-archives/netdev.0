From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-mm4
Date: Thu, 29 Jun 2006 22:39:33 +0200
Message-ID: <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com>
References: <20060629013643.4b47e8bd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:40408 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932447AbWF2UkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:40:08 -0400
Received: by py-out-1112.google.com with SMTP id b36so420065pyb
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 13:39:34 -0700 (PDT)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060629013643.4b47e8bd.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 29/06/06, Andrew Morton <akpm@osdl.org> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17/2.6.17-mm4/
>
>

This looks very strange.

BUG: unable to handle kernel paging request at virtual address 6b6b6c07
printing eip:
c0138594
*pde=00000000
Oops: 0002 [#1]
4K_STACK PREEMPT SMP
last sysfs file /class/net/eth0/address
Modules linked in: ipv6 af_packet ipt_REJECT xt_tcpudp x_tables
p4_clockmod speedstep_lib binfmt_misc

(gdb) list *0xc0138594
0xc0138594 is in __lock_acquire (include2/asm/atomic.h:96).
warning: Source file is more recent than executable.

91       *
92       * Atomically increments @v by 1.
93       */
94      static __inline__ void atomic_inc(atomic_t *v)
95      {
96              __asm__ __volatile__(
97                      LOCK_PREFIX "incl %0"
98                      :"=m" (v->counter)
99                      :"m" (v->counter));
100     }

Here is a config file
http://www.stardust.webpages.pl/files/mm/2.6.17-mm4/mm-config

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
