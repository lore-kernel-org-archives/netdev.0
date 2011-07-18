From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()
Date: Mon, 18 Jul 2011 16:06:54 +0200
Message-ID: <4E243DFE.4080100@trash.net>
References: <1309416426.2532.119.camel@edumazet-laptop>	 <4E0C278B.7010403@yandex.ru>	 <1309433652.1994.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E0C651A.1000300@trash.net>	 <1309446900.1994.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4E0C8902.8070303@earthlink.net> <4E0C8D7F.3000902@trash.net>	 <1309453730.5846.31.camel@tiger.regit.org>	 <1309455919.2515.3.camel@edumazet-laptop>	 <1309503610.2515.18.camel@edumazet-laptop>	 <20110701074936.GR16021@Chamillionaire.breakpoint.cc> <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, Eric Leblond <eric@regit.org>,
	sclark46@earthlink.net, Kuzin Andrey <kuzinandrey@yandex.ru>,
	Anders Nilsson Plymoth <lanilsson@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1309534078.2599.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.07.2011 17:27, Eric Dumazet wrote:
> [PATCH 1/2] nfnetlink: add RCU in nfnetlink_rcv_msg()
> 
> Goal of this patch is to permit nfnetlink providers not mandate
> nfnl_mutex being held while nfnetlink_rcv_msg() calls them.
> 
> If struct nfnl_callback contains a non NULL call_rcu(), then
> nfnetlink_rcv_msg() will use it instead of call() field, holding
> rcu_read_lock instead of nfnl_mutex
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Florian Westphal <fw@strlen.de>
> CC: Eric Leblond <eric@regit.org>
> CC: Patrick McHardy <kaber@trash.net>

Applied, thanks Eric.
