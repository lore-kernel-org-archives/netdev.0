From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] xtables: make XT_ALIGN() usable in exported headers
 by exporting __ALIGN_KERNEL()
Date: Tue, 13 Apr 2010 14:10:05 +0200
Message-ID: <4BC45F1D.3030301@trash.net>
References: <20100407162245.GA4557@x200> <4BC437C6.8020602@trash.net> <4BC44117.80901@trash.net> <20100414120712.GA25686@x200> <4BC450A4.1010200@trash.net> <20100414125007.GB25686@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, bhutchings@solarflare.com, andreas@fatal.se,
	hadi@cyberus.ca, hideaki@yoshifuji.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100414125007.GB25686@x200>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Tue, Apr 13, 2010 at 01:08:20PM +0200, Patrick McHardy wrote:
>> Alexey Dobriyan wrote:
>>> XT_ALIGN() was rewritten through ALIGN() by commit 42107f5009da223daa800d6da6904d77297ae829
>>> "netfilter: xtables: symmetric COMPAT_XT_ALIGN definition".
>>> ALIGN() is not exported in userspace headers, which created compile problem for tc(8)
>>> and will create problem for iptables(8).
>>>
>>> We can't export generic looking name ALIGN() but we can export less generic
>>> __ALIGN_KERNEL() (suggested by Ben Hutchings).
>>> Google knows nothing about __ALIGN_KERNEL().
>>>
>>> COMPAT_XT_ALIGN() changed for symmetry.
>> I've already pushed your change out, could you send me an incremental
>> fix please?
>>
>> master.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
> 
> [PATCH] Restore __ALIGN_MASK()
> 
> Fix lib/bitmap.c compile failure due to __ALIGN_KERNEL changes.

Applied.
