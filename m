From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Wed, 1 Feb 2012 10:14:46 +0100
Message-ID: <CAFLxGvwh5J=CR6OzST7ok6cEuHPWTziDN5TSbGxAiJOpANpAAQ@mail.gmail.com>
References: <1327269381-20748-1-git-send-email-richard@nod.at>
	<1327269381-20748-2-git-send-email-richard@nod.at>
	<CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com>
	<alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	eric.dumazet@gmail.com, Pablo Neira Ayuso <pablo@netfilter.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 1, 2012 at 2:24 AM, Jan Engelhardt <jengelh@medozas.de> wrote:
> On Monday 2012-01-30 10:01, richard -rw- weinberger wrote:
>
>>On Sun, Jan 22, 2012 at 10:56 PM, Richard Weinberger <richard@nod.at> wrote:
>>> ipt_LOG and ip6_LOG have a lot of common code, merge them
>>> to reduce duplicate code.
>>>
>>> Signed-off-by: Richard Weinberger <richard@nod.at>
>>
>>No comments?
>
> Adding Pablo to Cc.
>
>
> Do you have the patchset as a retrievable git tree, btw?

Only for kernel stuff:
git://git.kernel.org/pub/scm/linux/kernel/git/rw/misc.git xt_LOG

If you want it for the user space part too, I can setup something...

>
>>[PATCH 6/6] iptables: xt_LOG: Add ring buffer support
>>
>>in libxt_LOG.c:
>>+.size = XT_ALIGN(sizeof(struct xt_log_info_v1) + sizeof(void *)),
>
> Why the extra void*?

The kernel space part of  xt_log_info_v1 differs from the user space struct,
it contains an extra pointer to the ring buffer context.

Iptables must not see this extra pointer because the kernel writes to it.

-- 
Thanks,
//richard
