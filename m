From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP (ARCH=ppc)
Date: Thu, 25 May 2006 20:52:44 +0200
Message-ID: <4475FCFC.5000701@trash.net>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org> <20060525070324.2ea16b0a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49067 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030331AbWEYSwq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 14:52:46 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060525070324.2ea16b0a.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>>http://bugzilla.kernel.org/show_bug.cgi?id=6613
>>
>>           Summary: iptables broken on 32-bit PReP (ARCH=ppc)
>>    Kernel Version: 2.6.17-rc4
>>            Status: NEW
>>          Severity: normal
>>             Owner: laforge@gnumonks.org
>>         Submitter: mroos@linux.ee
>>
>>
>>Most recent kernel where this bug did not occur: none known, this is a fresh 
>>install
>>Distribution: Debian unstable
>>Hardware Environment: 32-bit PowerPC 604 with PReP subarch (using old 
>>ARCH=ppc)
>>Software Environment: usual 32-bit ppc userspace, gcc 4.0.3
>>Problem Description: iptables operations usually just give "Incalida 
>>operation". modprobe iptable_filter and adding rules to the nat table have 
>>failed in testing while iptable_nat can be modprobed and listed.
>>
>>Steps to reproduce:
>>modprobe iptable_filter (errors out with Invalid Argument)
>>iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -j SNAT --to 192.168.1.1 (usually 
>>errors out with Invalid Argument, sometimes succeeds, when succeeds then the 
>>rule works fine)


Meelis, it would really help if you could try 2.6.16 and in case
that doesn't work 2.6.15 to give an idea about whether this is a
recent regression or an old problem. We had a number of changes
in this area in the last two kernel versions that could be related.

