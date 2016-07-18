From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 17:18:41 +0200
Message-ID: <20160718151841.GA19066@breakpoint.cc>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51237 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbcGRPS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 11:18:59 -0400
Content-Disposition: inline
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kan.liang@intel.com <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
> 
> It is a big challenge to get good network performance. First, the network
> performance is not good with default system settings. Second, it is too
> difficult to do automatic tuning for all possible workloads, since workloads
> have different requirements. Some workloads may want high throughput.

Seems you did lots of tests to find optimal settings for a given base
policy.

What is missing in the kernel UAPI so userspace could do these settings
on its own, without adding this policy stuff to the kernel?

It seems strange to me to add such policies to the kernel.
Addmittingly, documentation of some settings is non-existent and one needs
various different tools to set this (sysctl, procfs, sysfs, ethtool, etc).

But all of these details could be hidden from user.
Have you looked at tuna for instance?
