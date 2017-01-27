From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [next-20170124] Kernel oops(rt6_fill_node) during reboot of LPAR
Date: Fri, 27 Jan 2017 08:34:15 -0700
Message-ID: <84f3cb86-5110-64a0-5575-4024ba758135@cumulusnetworks.com>
References: <9520531C-6458-4442-9ED5-3598E72C7C6A@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org,
        Stephen Rothwell <sfr@canb.auug.org.au>, davem@davemloft.net,
        Michael Ellerman <michael@ellerman.id.au>
To: Sachin Sant <sachinp@linux.vnet.ibm.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33087 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754903AbdA0PfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:35:09 -0500
Received: by mail-pg0-f52.google.com with SMTP id 204so82217923pge.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 07:34:18 -0800 (PST)
In-Reply-To: <9520531C-6458-4442-9ED5-3598E72C7C6A@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/17 5:54 AM, Sachin Sant wrote:
> While rebooting PowerVM LPAR running 4.10.0-rc5-next-20170124
> on a POWER8 box, following kernel oops is displayed.
> 
> This problem was introduced with next-20170123. next-20170120 works.
> Initial analysis points to following patch included with next-20170123
> 
> commit a1a22c12060e4b9c52f45d4b3460f614e00162a2
> net: ipv6: Keep nexthop of multipath route on admin down

Thanks for the report. Fixed by:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f17e2f2c8a8be3430813119fa7b633398f6185b
