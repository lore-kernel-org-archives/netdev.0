From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xtables: make XT_ALIGN() usable in exported headers by
 exporting __ALIGN_KERNEL()
Date: Tue, 13 Apr 2010 11:22:14 +0200
Message-ID: <4BC437C6.8020602@trash.net>
References: <20100407162245.GA4557@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, bhutchings@solarflare.com, andreas@fatal.se,
	hadi@cyberus.ca, hideaki@yoshifuji.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45363 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab0DMJWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:22:16 -0400
In-Reply-To: <20100407162245.GA4557@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> XT_ALIGN() was rewritten through ALIGN() by commit 42107f5009da223daa800d6da6904d77297ae829
> "netfilter: xtables: symmetric COMPAT_XT_ALIGN definition".
> ALIGN() is not exported in userspace headers, which created compile problem for tc(8)
> and will create problem for iptables(8).
> 
> We can't export generic looking name ALIGN() but we can export less generic
> __ALIGN_KERNEL() (suggested by Ben Hutchings).
> Google knows nothing about __ALIGN_KERNEL().
> 
> COMPAT_XT_ALIGN() changed for symmetry.

Since there haven't been any objections, I've applied your patch.
Thanks.
