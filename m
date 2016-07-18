From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 10:52:17 -0700
Message-ID: <CAM_iQpVRfoC0e43Pbsw8Q3RsyDDnMZeGu=oS0iVvAfMNwz6DeA@mail.gmail.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <20160718151841.GA19066@breakpoint.cc> <20160718154512.GK5871@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, kan.liang@intel.com,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>, ben@decadent.org.uk,
	decot@googlers.com, Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718154512.GK5871@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 8:45 AM, Andi Kleen <andi@firstfloor.org> wrote:
>> It seems strange to me to add such policies to the kernel.
>> Addmittingly, documentation of some settings is non-existent and one needs
>> various different tools to set this (sysctl, procfs, sysfs, ethtool, etc).
>
> The problem is that different applications need different policies.
>
> The only entity which can efficiently negotiate between different
> applications' conflicting requests is the kernel. And that is pretty
> much the basic job description of a kernel: multiplex hardware
> efficiently between different users.
>
> So yes the user space tuning approach works for simple cases
> ("only run workloads that require the same tuning"), but is ultimately not
> very interesting nor scalable.

I don't read the code yet, just the cover letter.

We have global tunings, per-network-namespace tunings, per-socket
tunings. It is still unclear why you can't just put different applications
into different namespaces/containers to get different policies.
