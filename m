From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 15:51:22 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07712C1968E@SHSMSX103.ccr.corp.intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"ben@decadent.org.uk" <ben@decade
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10488 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbcGRPv0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 11:51:26 -0400
In-Reply-To: <20160718151841.GA19066@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> >
> > It is a big challenge to get good network performance. First, the
> > network performance is not good with default system settings. Second,
> > it is too difficult to do automatic tuning for all possible workloads,
> > since workloads have different requirements. Some workloads may want
> high throughput.
> 
> Seems you did lots of tests to find optimal settings for a given base policy.
> 
Yes. Current test only base on Intel i40e driver. The optimal settings should
vary for other devices. But adding settings for new device is not hard.

> What is missing in the kernel UAPI so userspace could do these settings on its
> own, without adding this policy stuff to the kernel?

The main purpose of the proposal is to simplify the configuration. Too many
options will let them confuse. 
For normal users, they just need to tell the kernel that they want high throughput
for the application. The kernel will take care of the rest.
So, I don't think we need an interface for user to set their own policy settings.

> 
> It seems strange to me to add such policies to the kernel.

But kernel is the only place which can merge all user's requests.

> Addmittingly, documentation of some settings is non-existent and one needs
> various different tools to set this (sysctl, procfs, sysfs, ethtool, etc).
> 
> But all of these details could be hidden from user.
> Have you looked at tuna for instance?

Not yet. Is there similar settings for network?

Thanks,
Kan
