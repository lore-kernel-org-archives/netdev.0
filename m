From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC V2 PATCH 00/25] Kernel NET policy
Date: Thu, 4 Aug 2016 17:03:32 -0700
Message-ID: <20160804170332.4304a907@xeon-e3>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Dec 2014 20:38:49 -0500
kan.liang@intel.com wrote:

>  5. Why disable IRQ balance?
>     A: Disabling IRQ balance is a common way (recommend way for some devices) to
>        tune network performance.

I appreciate that network tuning is hard, most people get it wrong, and nobody
agrees on the right answer.

So rather than fixing existing tools or writing new userspace tools to do network
tuning, you want to hard code one policy manager in kernel with a /proc interface.
Why not make a good userspace tool (like powertop). There are also several IRQ
balancing programs, but since irqbalance was championed by one vendor others seem
to follow like sheep.

I agree that this a real concern but the implementation of this leaves much
to be desired and discussed. Why can't this be done outside of the kernel.
