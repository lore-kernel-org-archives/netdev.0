From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:30:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922133011.5885640b.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
	<4151DB6C.8050906@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <4151DB6C.8050906@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 13:07:08 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Andi, was that with a netperf TCP stream test? I
> would not have thought there would be no difference
> prior to the changes DaveM made recently (now we
> obey congestion window). We certainly got quite a bit
> of a difference running SPECWeb etc, but that was on
> the e1000s.

A netperf single stream TCP test and something like
SpecWEB are two different animals.

The former rarely goes faster with TSO enabled simply
because there is sufficient cpu and bus bandwidth to
keep the card full.

Whereas with something like SpecWEB the extra cpu and
bus cycles are needed by other resources of the benchmark
and thus performance goes up.

I have no idea why people think TSO will make some single
stream TCP test go faster, it doesn't buy you more bytes
on the wire :-)
