From: Meelis Roos <mroos@linux.ee>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Wed, 24 May 2006 12:20:27 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605241219450.27317@math.ut.ee>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee> <446765CC.8020500@trash.net>
 <Pine.SOC.4.61.0605152028420.9077@math.ut.ee> <4468CB51.4060707@trash.net>
 <Pine.SOC.4.61.0605152227290.8543@math.ut.ee> <4468D823.5090802@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:3325 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S932542AbWEXJUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 05:20:32 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4468D823.5090802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> 32-bit kernel, this is a Motorola Powerstack II macine with 604e. PReP
>> subarch, only buildable from the old ARCH=ppc code (not yet migrated to
>> ARCH=powerpc).
>
> Ah OK, I thought it was related to the new compat code, but that isn't
> the case. Your trace doesn't give much clues, except that it shows that
> iptables dies with a SIGSEGV, which might be a bug in userspace or in
> the kernel. Which was the last kernel that worked for you, and can you
> try that version again to rule out userspace bugs?

Even worse. With yesterdays git iptable_nat loads but iptable_filter 
doesn't even load (Invalid argument).

-- 
Meelis Roos (mroos@linux.ee)
