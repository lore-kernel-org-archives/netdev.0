From: Meelis Roos <mroos@linux.ee>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Mon, 15 May 2006 20:29:14 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605152028420.9077@math.ut.ee>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee> <446765CC.8020500@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:3205 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1750807AbWEOR3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 13:29:18 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <446765CC.8020500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Iptables seems to be broken on ppc for me. Kernel 2.6.17-rc3 (currently
>> compiling rc4+git). 32-bit ppc, ARCH=ppc with PReP target. Iptables
>> userland binary is from the latest Debian unstable (1.3.3-2).
>>
>> The symptoms: iptables usually just tells Invalid Argument on any
>> modification attempt. I'm trying to set up a simple one-rule NAT for test:
>> iptables -t nat -A POSTROUTING -s 172.30.0.0/24 -j SNAT --to 10.0.0.1
>> and it usually fails but has succeeded 2 times (I now have 2 rules of
>> this kind and they seem to just wotk once set up). Trying to delete the
>> second rule (either by replacing -A with -D or using just -D 2) gives
>> the same error.
>
>
> This should already be fixed in -rc4.

Unfortunately it was still there with yesterdays rc4+git.

-- 
Meelis Roos (mroos@linux.ee)
