From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Mon, 1 Dec 2003 15:50:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201155005.1c515793.davem@redhat.com>
References: <20031201204700.GA20349@gondor.apana.org.au>
	<Pine.LNX.4.44.0312020120020.2728-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312020120020.2728-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 01:30:17 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	I would suspect all rth->fl.fl4_tos checks too.
> It seems we need toskeys[2] and a second for loop if tos!=0.
> What about rewriting them to (rth->fl.fl4_tos == toskeys[j]).

I disagree, and this is related to my most recent email
in this thread.

This packet we are reacting to for PMTU purposes could only
have come from us if the TOS matches precisely.
