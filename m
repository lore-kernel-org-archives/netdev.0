From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/12] netfilter: x_tables: align per cpu xt_counter
Date: Mon, 22 Jun 2015 15:27:31 +0200
Message-ID: <1434979651.4110.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
	 <1434734269-4545-4-git-send-email-pablo@netfilter.org>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB54634@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Pablo Neira Ayuso' <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB54634@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-06-22 at 11:49 +0000, David Laight wrote:
> From: Pablo Neira Ayuso
> > Sent: 19 June 2015 18:18
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Let's force a 16 bytes alignment on xt_counter percpu allocations,
> > so that bytes and packets sit in same cache line.
> > 
> > xt_counter being exported to user space, we cannot add __align(16) on
> > the structure itself.
> 
> You could allocate a wrapper structure that contains xt_counter
> and is itself marked __align(16).

Sure. I took one solution, out of multiple ones.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
