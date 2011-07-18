From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] nfnetlink_queue: provide rcu enabled callbacks
Date: Mon, 18 Jul 2011 16:09:04 +0200
Message-ID: <4E243E80.6010509@trash.net>
References: <1309534142.2599.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, sclark46@earthlink.net,
	Eric Leblond <eric@regit.org>,
	Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1309534142.2599.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.07.2011 17:29, Eric Dumazet wrote:
> nenetlink_queue operations on SMP are not efficent if several queues are
> used, because of nfnl_mutex contention when applications give packet
> verdict.
> 
> Use new call_rcu field in struct nfnl_callback to advertize a callback
> that is called under rcu_read_lock instead of nfnl_mutex.
> 
> On my 2x4x2 machine, I was able to reach 2.000.000 pps going through
> user land returning NF_ACCEPT verdicts without losses, instead of less
> than 500.000 pps before patch.

Applied, nice work.
