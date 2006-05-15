From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Mon, 15 May 2006 21:36:03 +0200
Message-ID: <4468D823.5090802@trash.net>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee> <446765CC.8020500@trash.net> <Pine.SOC.4.61.0605152028420.9077@math.ut.ee> <4468CB51.4060707@trash.net> <Pine.SOC.4.61.0605152227290.8543@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45772 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751601AbWEOTgF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 15:36:05 -0400
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0605152227290.8543@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
>>>> This should already be fixed in -rc4.
>>>
>>>
>>> Unfortunately it was still there with yesterdays rc4+git.
>>
>>
>> I may have misinterpreted your report - are you running a 32bit or 64bit
>> kernel?
> 
> 
> 32-bit kernel, this is a Motorola Powerstack II macine with 604e. PReP
> subarch, only buildable from the old ARCH=ppc code (not yet migrated to
> ARCH=powerpc).

Ah OK, I thought it was related to the new compat code, but that isn't
the case. Your trace doesn't give much clues, except that it shows that
iptables dies with a SIGSEGV, which might be a bug in userspace or in
the kernel. Which was the last kernel that worked for you, and can you
try that version again to rule out userspace bugs?

