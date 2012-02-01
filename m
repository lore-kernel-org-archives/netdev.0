From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Wed, 1 Feb 2012 02:24:11 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
References: <1327269381-20748-1-git-send-email-richard@nod.at> <1327269381-20748-2-git-send-email-richard@nod.at> <CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	eric.dumazet@gmail.com, Pablo Neira Ayuso <pablo@netfilter.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2012-01-30 10:01, richard -rw- weinberger wrote:

>On Sun, Jan 22, 2012 at 10:56 PM, Richard Weinberger <richard@nod.at> wrote:
>> ipt_LOG and ip6_LOG have a lot of common code, merge them
>> to reduce duplicate code.
>>
>> Signed-off-by: Richard Weinberger <richard@nod.at>
>
>No comments?

Adding Pablo to Cc.


Do you have the patchset as a retrievable git tree, btw?


>[PATCH 6/6] iptables: xt_LOG: Add ring buffer support
>
>in libxt_LOG.c:
>+.size = XT_ALIGN(sizeof(struct xt_log_info_v1) + sizeof(void *)),

Why the extra void*?
