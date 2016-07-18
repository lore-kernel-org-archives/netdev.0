From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 08:45:12 -0700
Message-ID: <20160718154512.GK5871@two.firstfloor.org>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com, andi@firstfloor.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:45780 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbcGRPpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 11:45:23 -0400
Content-Disposition: inline
In-Reply-To: <20160718151841.GA19066@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It seems strange to me to add such policies to the kernel.
> Addmittingly, documentation of some settings is non-existent and one needs
> various different tools to set this (sysctl, procfs, sysfs, ethtool, etc).

The problem is that different applications need different policies.

The only entity which can efficiently negotiate between different
applications' conflicting requests is the kernel. And that is pretty 
much the basic job description of a kernel: multiplex hardware
efficiently between different users.

So yes the user space tuning approach works for simple cases
("only run workloads that require the same tuning"), but is ultimately not
very interesting nor scalable.

-Andi
