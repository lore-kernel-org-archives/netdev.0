From: Prasanna Meda <pmeda@akamai.com>
Subject: Re: rcv_wnd = init_cwnd*mss
Date: Thu, 28 Oct 2004 17:55:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41819514.C25D7A51@akamai.com>
References: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B08@usca1ex-priv1.sanmateo.corp.akamai.com> <20041028165658.753eee50.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:

> On Wed, 27 Oct 2004 23:15:48 -0700
> "Meda, Prasanna" <pmeda@akamai.com> wrote:
>
> > Thanks, still it is unclear to me why are we
> > downsizing the advertised window(rcv_wnd) to cwnd?
> > To defeat disobeying sender, or something like below?
>
> There is never any reason to advertise a receive window
> larger than the initial congestion window of the sender
> could ever be.
>
> Setting it properly like this also makes sure that we do
> receive window update events at just the right place as
> the sender starts sending us the initial data frames.

That makes sense!

But are we coping with cwnd increase on sender?
Looks rcv rwnd s updated by only 1 pkt at time.


Thanks,
Prasanna.
