From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Fri, 23 Aug 2013 16:42:28 +0200
Message-ID: <20130823164228.1bc92a48@redhat.com>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	<1369244868.3301.343.camel@edumazet-glaptop>
	<20130524151647.18388e27@redhat.com>
	<1369403496.3301.401.camel@edumazet-glaptop>
	<20130527143346.2d19e854@redhat.com>
	<20130527123656.GA16212@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130527123656.GA16212@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On Mon, 27 May 2013 14:36:56 +0200
Pablo Neira Ayuso <pablo@netfilter.org> wrote:

> On Mon, May 27, 2013 at 02:33:46PM +0200, Jesper Dangaard Brouer wrote:
> > On Fri, 24 May 2013 06:51:36 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > On Fri, 2013-05-24 at 15:16 +0200, Jesper Dangaard Brouer wrote:
> > [...cut...]
> > > > I'm amazed, this patch will actually make it a viable choice to load
> > > > the conntrack modules on a DDoS based filtering box, and use the
> > > > conntracks to protect against ACK and SYN+ACK attacks.
> > > > 
> > > > Simply by not accepting the ACK or SYN+ACK to create a conntrack
> > > > entry. Via the command:
> > > >  sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
> > > > 
> > > > A quick test show; now I can run a LISTEN process on the port, and
> > > > handle an SYN+ACK attack of approx 2580Kpps (and the same for ACK
> > > > attacks), while running a LISTEN process on the port.
> > > > 
> > [...]
> > > > 
> > > 
> > > Wow, this is very interesting !
> > > 
> > > Did you test the thing when expectations are possible ? (say ftp
> > > module loaded)
> > 
> > Nope. I'm not sure how to create a test case, that causes an
> > expectation to be created.
> 
> This is still in my queue, I didn't forget about this. I need to find
> some spare time to give this a test with expectations enabled and also
> with conntrackd/state-sync.

What about this patch, what is the status?
Is it still on you queue, or did it get applied without me noticing?


Link for people wanting to read-up on thread:
 http://thread.gmane.org/gmane.linux.network/268758/
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
