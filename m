From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:12:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <c0a09e5c04092213126ba5f29d@mail.gmail.com>
References: <20040920063012.GL2825@krispykreme>
	 <20040920203021.GD4242@wotan.suse.de>
	 <20040921155835.18aee381.davem@davemloft.net>
	 <20040922140000.GD27432@wotan.suse.de>
	 <20040922111209.7887df53.davem@davemloft.net>
	 <20040922195515.GA2619@wotan.suse.de>
Reply-To: Andrew Grover <andy.grover@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922195515.GA2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 21:55:15 +0200, Andi Kleen <ak@suse.de> wrote:
> With tso off i get the same performance as on 2.6.5.
> 
> I must add that this is a CSA e1000 (directly integrated into
> the chipset and doesn't use PCI) and TSO doesn't seem to be
> bring any advantage. On 2.6.5 the performance is the same
> with both TSO on or off.

I think this is caused by the congestion changes added between
2.6.9-rc1 and rc2. I am seeing good performance with rc1 and tso on
(or off), but bad performance with rc2 and bk-latest only if tso is
on.

Regards -- Andy
