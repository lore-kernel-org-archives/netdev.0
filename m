From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 13:52:06 +0800
Message-ID: <AANLkTimcC25cy-xH-QfaX8t5_2trM7UEiJnRS3zhu6T_@mail.gmail.com>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>
	<1279862843.2482.16.camel@edumazet-laptop> <1279863633.2482.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279863633.2482.22.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 1:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Reading again your patch, I understand only the Changelog is wrong.
>
> We want to copy quota back to userspace, as specified when rule was
> setup (so that iptables-save works)
>
> The real thing you are doing is that we dont change the initial quota
> during packet processing, only the private quota, shared by all cpus.
>
> Before the patch , iptables -nvL could report an old and not accurate
> quota value.
>
> After the patch, iptables -nvL reports the initial quota value, not the
> actual value.
>

Yes. This module was expected to report the current quota value, when
iptables -nvL or iptables-save  was executed. It seems my patch
changes its ABI. However, report the initial value is also meaningful,
and it keeps the same behavior as the other modules do.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
