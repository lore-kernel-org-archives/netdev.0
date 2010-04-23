From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 12:35:41 +0200
Message-ID: <4BD177FD.9020904@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com> <1271943066.14501.194.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271943066.14501.194.camel@jdb-workstation>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> I have added a stats counter to prove my case, which I think we should add to the kernel (to detect the case in the future).
> The DDoS attack has disappeared, so I guess I'll try to see if I can reproduce the problem in my testlab.
> 
> 
> 
> [PATCH] net: netfilter conntrack extended with extra stat counter.
> 
> From: Jesper Dangaard Brouer <hawk@comx.dk>
> 
> I suspect an unfortunatly series of events occuring under a DDoS
> attack, in function __nf_conntrack_find() nf_contrack_core.c.
> 
> Adding a stats counter to see if the search is restarted too often.

Applied, thanks Jesper.
