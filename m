From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Thu, 15 Jul 2010 13:58:34 +0200
Message-ID: <4C3EF7EA.2040900@nets.rwth-aachen.de>
References: <4C358AAA.9080400@kernel.org> <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm testing new reordering algorithms in a virtual testbed, that is the 
nodes are emulated with xen and all the network parameters can be tuned 
with queues.
With one of the algorithms I also got tracebacks which include 
tcp_xmit_retransmit_queue. It only happens with ACK loss. The kernel 
version however is 2.6.31.
When I read this thread I tried the debug patch and got the following:

[ 2754.413150] NULL head, pkts 0
[ 2754.413156] Errors caught so far 1

Hope that is of any help.
