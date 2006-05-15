From: Meelis Roos <mroos@linux.ee>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Mon, 15 May 2006 23:07:59 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605152300320.17100@math.ut.ee>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee> <446765CC.8020500@trash.net>
 <Pine.SOC.4.61.0605152028420.9077@math.ut.ee> <4468CB51.4060707@trash.net>
 <Pine.SOC.4.61.0605152227290.8543@math.ut.ee> <4468D823.5090802@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:12793 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S965206AbWEOUIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 16:08:02 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4468D823.5090802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Ah OK, I thought it was related to the new compat code, but that isn't
> the case. Your trace doesn't give much clues, except that it shows that
> iptables dies with a SIGSEGV, which might be a bug in userspace or in
> the kernel. Which was the last kernel that worked for you, and can you
> try that version again to rule out userspace bugs?

It's a fresh install in the new role with a new HDD and 2 NICs for a 
firewall so I have not tried earlier kernels with iptables. I do have 
sarge's 2.6.8 also working on that machine but not the kernels from 
testing and unstable (2.5.15 and 2.6.16) because the lack of prep 
support at the moment. I could problably compile some intermediate 
kernels but I haven't tested even the working 2.6.8 first with iptables 
yet.

I will be away tomorrow but can test some kernels the day after 
tomorrow. Only some of them because it's not a fast compile engine.

It only SIGSEGVs when ptraced and just gets Invalid Argument errors when 
not traced so this SEGV may be something different (perhaps ptrace 
related).

-- 
Meelis Roos (mroos@linux.ee)
