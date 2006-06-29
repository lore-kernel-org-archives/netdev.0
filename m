From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.17-mm4
Date: Thu, 29 Jun 2006 22:46:24 +0200
Message-ID: <6bffcb0e0606291346s64530db4g1c9c33da9cf34e73@mail.gmail.com>
References: <20060629013643.4b47e8bd.akpm@osdl.org>
	 <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com>
	 <20060629204330.GC13619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:56555 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932503AbWF2UqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:46:25 -0400
Received: by py-out-1112.google.com with SMTP id b36so422604pyb
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 13:46:25 -0700 (PDT)
To: "Dave Jones" <davej@redhat.com>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"Andrew Morton" <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
In-Reply-To: <20060629204330.GC13619@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/06/06, Dave Jones <davej@redhat.com> wrote:
> On Thu, Jun 29, 2006 at 10:39:33PM +0200, Michal Piotrowski wrote:
>
>  > This looks very strange.
>  >
>  > BUG: unable to handle kernel paging request at virtual address 6b6b6c07
>
> Looks like a use after free.
>
>  > printing eip:
>  > c0138594
>  > *pde=00000000
>  > Oops: 0002 [#1]
>  > 4K_STACK PREEMPT SMP
>  > last sysfs file /class/net/eth0/address
>  > Modules linked in: ipv6 af_packet ipt_REJECT xt_tcpudp x_tables
>  > p4_clockmod speedstep_lib binfmt_misc
>  >
>  > (gdb) list *0xc0138594
>  > 0xc0138594 is in __lock_acquire (include2/asm/atomic.h:96).
>  > warning: Source file is more recent than executable.
>
> got a backtrace ?

Unfortunately no.

>
>                 Dave
>
> --
> http://www.codemonkey.org.uk
>

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
