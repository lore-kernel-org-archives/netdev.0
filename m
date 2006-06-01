From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Thu, 1 Jun 2006 10:03:48 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0606011002180.13777@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:1008 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1750720AbWFAHD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 03:03:57 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4475FCFC.5000701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> modprobe iptable_filter (errors out with Invalid Argument)
>>> iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -j SNAT --to 192.168.1.1 (usually
>>> errors out with Invalid Argument, sometimes succeeds, when succeeds then the
>>> rule works fine)
>
> Meelis, it would really help if you could try 2.6.16 and in case
> that doesn't work 2.6.15 to give an idea about whether this is a
> recent regression or an old problem. We had a number of changes
> in this area in the last two kernel versions that could be related.

Have not gotten 2.6.15 to work with one evening of tinkering - the irq 
patch was not sufficent, there is something more broken in booting that 
I dodn't figure out yet. So no test results for 2.6.15 yet.

-- 
Meelis Roos (mroos@linux.ee)
