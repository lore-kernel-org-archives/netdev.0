From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC PATCH] netfilter: remove the duplicate tables
Date: Fri, 19 Nov 2010 20:48:37 +0800
Message-ID: <AANLkTikF83kxggqyxoxw0m6L5km3zogPsiV7wVO1jbXy@mail.gmail.com>
References: <1290091194-1590-1-git-send-email-xiaosuo@gmail.com>
 <1290095020.2781.203.camel@edumazet-laptop> <alpine.LNX.2.01.1011191210290.29394@obet.zrqbmnf.qr>
 <1290166180.3034.119.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290166180.3034.119.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 19, 2010 at 7:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> IMHO, the real problem is not the table duplication. We know that adding
> a level of indirection is going to hurt a lot because of cache misses.
>

Currently, multi-core CPU is common, the cores in a CPU share the
lowest level cache. Duplicate tables use more RAM, and may cause more
pressure of the lowest level cache.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
