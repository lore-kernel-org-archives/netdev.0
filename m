From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Tue, 12 Jul 2016 16:25:17 +0200
Message-ID: <20160712142517.GA1919@salvia>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc>
 <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc>
 <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
 <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
 <20160705122803.GA26862@salvia>
 <CAB9dFdv_ShA2cSez7Ut31XnW7OWufV59bfG-zN4Z0K3CgPvwuA@mail.gmail.com>
 <20160711162642.GA5462@salvia>
 <CAB9dFdv8zzODKMr2Ane8jSKxNhJdDMyPZ8YaYJqL1cW0TFOO4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Thorsten Leemhuis <regressions@leemhuis.info>,
	netfilter-devel@vger.kernel.org
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56158 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933032AbcGLOZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 10:25:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 37BA2392E0B
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 16:25:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2507B26674C
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 16:25:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2A2049EBA9
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 16:25:19 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <CAB9dFdv8zzODKMr2Ane8jSKxNhJdDMyPZ8YaYJqL1cW0TFOO4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 06:17:39PM -0300, Marc Dionne wrote:
> Hi Pablo,
> 
> Testing out your patch:
> 
> 1) With no NAT in place, the clash resolution happens, with no side
> effects.  No EPERM errors are seen.
> 
> 2) With ip(6)table_nat loaded, the clash resolution fails and I get
> some EPERM errors from sendmsg(), same as before 71d8c47fc653.
> 
> Turns out that even though I have no NAT rules in my iptables config,
> the system also had firewalld active and that caused the modules to be
> loaded.
> 
> So the bottom line is that the patch looks good to me..

Thanks Marc, I'm going to apply this then.
