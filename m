From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:56:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4151E6F1.7000405@us.ibm.com>
References: <20040920063012.GL2825@krispykreme>	<20040920203021.GD4242@wotan.suse.de>	<20040921155835.18aee381.davem@davemloft.net>	<20040922140000.GD27432@wotan.suse.de>	<20040922111209.7887df53.davem@davemloft.net>	<20040922195515.GA2619@wotan.suse.de>	<4151DB6C.8050906@us.ibm.com> <20040922133011.5885640b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040922133011.5885640b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> The former rarely goes faster with TSO enabled simply
> because there is sufficient cpu and bus bandwidth to
> keep the card full.

At about 700MHz (ok, old, I know) or thereabouts, it
usually took > 1 CPU to drive a gigabit card, iirc,
about 1.5 CPUs or so.

> Whereas with something like SpecWEB the extra cpu and
> bus cycles are needed by other resources of the benchmark
> and thus performance goes up.

Yep..

> I have no idea why people think TSO will make some single
> stream TCP test go faster, it doesn't buy you more bytes
> on the wire :-)

True, if the card was already doing line speed,
no, as you say, it won't help making the stack go
faster :). If not, though, the gain in doing only
one pass down the stack, one route look up, etc in
place of multiple handoffs should help, correct?

thanks,
Nivedita
