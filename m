From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Thu, 25 May 2006 07:03:24 -0700
Message-ID: <20060525070324.2ea16b0a.akpm@osdl.org>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4044 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030191AbWEYOEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 10:04:04 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6613
> 
>            Summary: iptables broken on 32-bit PReP (ARCH=ppc)
>     Kernel Version: 2.6.17-rc4
>             Status: NEW
>           Severity: normal
>              Owner: laforge@gnumonks.org
>          Submitter: mroos@linux.ee
> 
> 
> Most recent kernel where this bug did not occur: none known, this is a fresh 
> install
> Distribution: Debian unstable
> Hardware Environment: 32-bit PowerPC 604 with PReP subarch (using old 
> ARCH=ppc)
> Software Environment: usual 32-bit ppc userspace, gcc 4.0.3
> Problem Description: iptables operations usually just give "Incalida 
> operation". modprobe iptable_filter and adding rules to the nat table have 
> failed in testing while iptable_nat can be modprobed and listed.
> 
> Steps to reproduce:
> modprobe iptable_filter (errors out with Invalid Argument)
> iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -j SNAT --to 192.168.1.1 (usually 
> errors out with Invalid Argument, sometimes succeeds, when succeeds then the 
> rule works fine)
> 
