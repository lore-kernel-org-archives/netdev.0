From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 23:56:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922215657.GB2619@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net> <20040922195515.GA2619@wotan.suse.de> <4151DB6C.8050906@us.ibm.com> <20040922133011.5885640b.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>, ak@suse.de, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040922133011.5885640b.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I have no idea why people think TSO will make some single
> stream TCP test go faster, it doesn't buy you more bytes
> on the wire :-)

It definitely helps on 10GB/s - without it the maximum
for single stream is slower. 

I suspect with a slow bus you can also see advantages
on 1Gb/s.

-Andi
