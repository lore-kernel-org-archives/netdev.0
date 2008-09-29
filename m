From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 09:52:03 +0400
Message-ID: <20080929055203.GA3460@2ka.mipt.ru>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:58418 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167AbYI2Fxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 01:53:53 -0400
Content-Disposition: inline
In-Reply-To: <20080929054052.GA23600@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 01:40:52PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> Are you using Xen FV or PV? What processor?

Can I determine that within guest?
I do not think so except by loking at cpu flags?

$ cat /proc/cpuinfo 
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 15
model name	: Intel(R) Xeon(R) CPU           E5345  @ 2.33GHz
stepping	: 11
cpu MHz		: 2333.406
cache size	: 4096 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr mce cx8 apic sep mtrr pge mca
cmov pat clflush dts mmx fxsr sse sse2 ss pbe syscall lm constant_tsc up
pebs bts pni ds_cpl ssse3 cx16 xtpr lahf_lm
bogomips	: 4666.81
clflush size	: 64
power management:

Actually it is a bit strange, if full or paravirtualization affects how
loopback network works, I thought it should only affect communication
between domains?

-- 
	Evgeniy Polyakov
