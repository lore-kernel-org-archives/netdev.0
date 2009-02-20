From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 20 Feb 2009 11:04:29 +0100
Message-ID: <499E802D.1010909@trash.net>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <499E7FA9.6070707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499E7FA9.6070707@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> While doing oprofile tests I noticed two loops are not properly unrolled by gcc
> 
> Using a hand coded unrolled loop provides nice speedup : ipt_do_table
> credited of 2.52 % of cpu instead of 3.29 % in tbench.

Applied, thanks Eric.
