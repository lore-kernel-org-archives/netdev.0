From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PTP + H/W time stamping + CONFIG_PREEMPT_RT_FULL == Oops in slab
Date: Thu, 21 Jun 2012 17:58:02 +0100
Message-ID: <1340297882.2736.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAGgcXb662=PbdJaMff1QfBhW06mYXgNvM1o6snunZMe=Q36Q7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: satpal parmar <systems.satpal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42377 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751644Ab2FUQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 12:58:07 -0400
In-Reply-To: <CAGgcXb662=PbdJaMff1QfBhW06mYXgNvM1o6snunZMe=Q36Q7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 20:09 +0530, satpal parmar wrote:
> Hi  All!
> 
> Recently  I successfully  integrated a certain
> (http://sourceforge.net/scm/?type=svn&group_id=503885) open source
> implementation of PTP protocol with Linux  3.0.1 running on ARM based
> SoC. Since Phy  (Phyter DP 83640) on board  supported  H/W time
> stamping support I am using for that for the same. Integration worked
> smoothly  until I applied RT patch and enabled full preemption
> (CONFIG_PREEMPT_RT_FULL).
[...]
> kernel BUG at /home/satpal/sandbox/console_p/trunk/bts/source/vendor/linux/mm/slab.c:3205!
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> pgd = e9e08000
> [00000000] *pgd=ae31c831, *pte=00000000, *ppte=00000000
> Internal error: Oops: 817 [#1] PREEMPT
> Modules linked in:
> CPU: 0    Not tainted  (3.0.1-rt11-svn7595 #29)
[...]

I suggest you re-test with 3.0.35-rt56; there have been many bug fixes.

Also might this 'vendor' kernel include its own changes to mm, net, etc.
that are not in mainline?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
