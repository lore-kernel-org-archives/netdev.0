From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning/Oops report of the week of August 7th, 2008
Date: Fri, 8 Aug 2008 22:24:08 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808082222570.18680@bizon.gios.gov.pl>
References: <489B179F.1080704@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Jones <davej@redhat.com>, NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:58108 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbYHHUZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 16:25:49 -0400
In-Reply-To: <489B179F.1080704@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 7 Aug 2008, Arjan van de Ven wrote:
<CUT>

> Rank 7: nf_conntrack_acct_fini (warning)
> 	Reported 67 times
> 	Bug in the netfilter procfs code exposed by Al's recent cleanups
> 	This warning was last seen in version 2.6.27-rc2, and first seen in 
> 2.6.27-rc1.
> 	More info: 
> http://www.kerneloops.org/searchweek.php?search=nf_conntrack_acct_fini

Should be fixed by:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=9714be7da8b32f36d2468fe08ff603b6402df8cf

Best regards,

 				Krzysztof Oledzki
