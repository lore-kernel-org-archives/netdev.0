From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/12] netfilter: nfnetlink_queue: enable UID/GID socket
 info retrieval
Date: Mon, 6 Jan 2014 17:36:49 +0100
Message-ID: <20140106163649.GA4910@localhost>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
 <1388963586-5049-4-git-send-email-pablo@netfilter.org>
 <1389022353.12212.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valentina Giusti <valentina.giusti@bmw-carit.de>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389022353.12212.176.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 07:32:33AM -0800, Eric Dumazet wrote:
> On Mon, 2014-01-06 at 00:12 +0100, Pablo Neira Ayuso wrote:
> > From: Valentina Giusti <valentina.giusti@bmw-carit.de>
> > 
> > Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388
> > (udp: ipv4: Add udp early demux) it is now possible to parse UID and
> > GID socket info also for incoming TCP and UDP connections. Having
> > this info available, it is convenient to let NFQUEUE parse it in
> > order to improve and refine the traffic analysis in userspace.
> > 
> > Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
[...]
> net/netfilter/nfnetlink_queue_core.c: In function 'nfqnl_put_sk_uidgid':
> net/netfilter/nfnetlink_queue_core.c:304:35: error: 'TCP_TIME_WAIT' undeclared (first use in this function)
> net/netfilter/nfnetlink_queue_core.c:304:35: note: each undeclared identifier is reported only once for each function it appears in
> make[3]: *** [net/netfilter/nfnetlink_queue_core.o] Error 1
> 
> Fix is obvious (#include <net/tcp_states.h>), but I have to run...

Just sent this patch to David, thanks for reporting.

http://patchwork.ozlabs.org/patch/307367/
