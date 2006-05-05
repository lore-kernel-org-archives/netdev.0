From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
Date: Fri, 05 May 2006 08:57:06 -0700
Message-ID: <445B75D2.6080702@candelatech.com>
References: <20060504235628.33041b55.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:38576 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751155AbWEEP5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 11:57:12 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060504235628.33041b55.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 4 May 2006 23:15:56 -0700
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 6495] New: Vlan MTU Fragmentation
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=6495
> 
>            Summary: Vlan MTU Fragmentation
>     Kernel Version: 2.6.16.12
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: slavon@bigtelecom.ru
> 
> 
> Steps to reproduce:
> 
> ifconfing eth0 mtu 1500
> ifconfing eth0.100 mtu 1500
> 
> ping www.ru -s 2000
> -- BAD --
> 
> ----------------
> 
> ifconfing eth0 mtu 1500
> ifconfing eth0.100 mtu 1496
> 
> ping www.ru -s 2000
> --NORMAL--

This is almost definately a bug in the ethernet driver.  The driver needs
to be modified so that it can send/receive pkts that are MTU + 4 bytes for the
VLAN header.

We need to know what NIC/driver this user is using...

Ben


> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

