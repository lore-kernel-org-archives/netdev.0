From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 02:07:00 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312020206100.2728-100000@u.domain.uli>
References: <20031201155005.1c515793.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031201155005.1c515793.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 1 Dec 2003, David S. Miller wrote:

> On Tue, 2 Dec 2003 01:30:17 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
>
> > 	I would suspect all rth->fl.fl4_tos checks too.
> > It seems we need toskeys[2] and a second for loop if tos!=0.
> > What about rewriting them to (rth->fl.fl4_tos == toskeys[j]).
>
> I disagree, and this is related to my most recent email
> in this thread.
>
> This packet we are reacting to for PMTU purposes could only
> have come from us if the TOS matches precisely.

	Ops, ip_rt_redirect matches output route to, hm, lets think
again about it...

Regards

--
Julian Anastasov <ja@ssi.bg>
