From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH nf-next] netfilter: xt_socket: add XT_SOCKET_NOWILDCARD
 flag
Date: Tue, 4 Jun 2013 16:30:53 +0200
Message-ID: <20130604163053.08c0d80f@redhat.com>
References: <1370300249.24311.190.camel@edumazet-glaptop>
	<20130604111014.73c718f7@redhat.com>
	<1370353617.24311.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370353617.24311.201.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 04 Jun 2013 06:46:57 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2013-06-04 at 11:10 +0200, Jesper Dangaard Brouer wrote:
> > On Mon, 03 Jun 2013 15:57:29 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > xt_socket module can be a nice replacement to conntrack module
> > > in some cases (SYN filtering for example)
> > > 
> > > But it lacks the ability to match the 3rd packet of TCP
> > > handshake (ACK coming from the client).
> > > 
> > > Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism
> > 
> > Sorry, but I'm not sure I understand your description.
> > 
> > What is the effect of adding the XT_SOCKET_NOWILDCARD flag?
> > It almost sound like it adds the ability to match the 3rd packet of
> > TCP handshake (ACK coming from the client), is that the case?
> > 
> 
> Well, if the found socket happens to be a LISTEN socket, we ignore the
> socket if it was bound to 0.0.0.0
> 
> Thats the wildcard thing in xt_socket. Not clear why its there, but
> thing is : we apparently have to keep this behavior by default.
> 
> So yes, the ACK packet from the client is not matched by current
> xt_socket.
> 
> After my patch, it is matched.
> 
> I CCed you because you mentioned using conntrack for SYN filtering :
> xt_socket can be a way to do the same thing without the conntrack
> overhead, for locally terminated traffic.

Thank you for Cc'ing me.  I didn't realize that the module could be
used in this manor.  Much appreciated! :-)

