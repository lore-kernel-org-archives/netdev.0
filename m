From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] nf_nat: make unique_tuple return void
Date: Sat, 31 Jul 2010 13:54:42 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007311352490.17359@obet.zrqbmnf.qr>
References: <1280542516-14567-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280542516-14567-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 2010-07-31 04:15, Changli Gao wrote:

>the only user of unique_tuple() get_unique_tuple() doesn't care about the
>return value of unique_tuple(), so make unique_tuple() return void (nothing).

Shouldn't the callers (get_unique_tuple in nf_nat_core.c) ideally 
return NF_DROP or something such that connections that cannot be 
uniquely mangled be rejected rather than forwarded without mangling?


