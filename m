From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: [2.6.9] Networking crash, slightly exotic setup, bridged
 tap/tun interfaces
Date: Wed, 15 Dec 2004 00:02:13 +1030
Message-ID: <20041215000213.77cc0fa0.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20041214105245.32c9b1a6.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<41BE2B20.5080602@conectiva.com.br>
	<20041214113036.3ccb3480.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<41BE320A.8090201@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41BE320A.8090201@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

On Mon, 13 Dec 2004 22:21:30 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Mark Smith wrote:
> > Hi Arnaldo,
> > 
<snip>

> >>
> >>Can you reproduce this with 2.6.10-rc3? 2.6.9 had several networking
> >>bugs fixed already in 2.6.10-rc3.
> >>
> > 

<snip>

2.6.10-rc3 has appeared to have "fixed" it, although I wasn't all that
sure what caused it in the first place. I'm running 2.6.10-rc3 on both
the main host and the Qemu virtual PCs.

I've been playing with the set up for the last couple of hours. I now
have 5 Qemu virtual PCs with 3 virtual NE2K NICs / 3 real host tun
interfaces running - at total of 15 host tun interfaces. I've now got
them interconnected via 6 separate (internal) bridges.

[root@ubu] > brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.00ff3761a7da       no              tun2
                                                        tun3
br1,3,5         8000.00ff3ae4ea7f       no              tun0
                                                        tun14
                                                        tun7
br1,4           8000.00ff17200d92       no              tun10
                                                        tun1
br1             8000.00ff08da3925       no              tun5
                                                        tun6
br2             8000.00ff312eed9e       no              tun8
                                                        tun9
br3             8000.00ff7a131b45       no              tun11
                                                        tun12
[root@ubu] >

The 5 Qemu instances are all now running OSPF, the main host (ubu),
where the Oops occured, is also running OSPF, and is attached
to the topology via bridges br1,3,5 and br1,4.

I'll leave it running overnight in this configuration to see how it
goes.

Thanks,
Mark.


-- 
