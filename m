From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:07:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4151DB6C.8050906@us.ibm.com>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net> <20040922195515.GA2619@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922195515.GA2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> With tso off i get the same performance as on 2.6.5.
> 
> I must add that this is a CSA e1000 (directly integrated into
> the chipset and doesn't use PCI) and TSO doesn't seem to be 
> bring any advantage. On 2.6.5 the performance is the same
> with both TSO on or off.

Andi, was that with a netperf TCP stream test? I
would not have thought there would be no difference
prior to the changes DaveM made recently (now we
obey congestion window). We certainly got quite a bit
of a difference running SPECWeb etc, but that was on
the e1000s.

Nivedita
