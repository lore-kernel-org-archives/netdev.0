From: jamal <hadi@cyberus.ca>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 12 Sep 2002 08:30:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209120811300.16149-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0209120119580.25406-100000@gp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
   "tcw@tempest.prismnet.com" <tcw@tempest.prismnet.com>,
   "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Todd Underwood <todd@osogrande.com>
In-Reply-To: <Pine.LNX.4.44.0209120119580.25406-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Good work. The first time i have seen someone say Linux's way of
reverse order is a GoodThing(tm). It was also great to see de-mything
some of the old assumption of the world.

BTW, TSO is not a intelligent as what you are suggesting.
If i am not mistaken you are not only suggesting fragmentation and
assembly at that level you are also suggesting retransmits at the NIC.
This could be dangerous for practical reasons (changes in TCP congestion
control algorithms etc). TSO as was pointed in earlier emails is just a
dumb sender of packets. I think even fragmentation is a misnomer.
Essentially you shove a huge buffer to the NIC and it breaks it into MTU
sized packets for you and sends them.

In regards to the receive side CPU utilization improvements: I think
that NAPI does a good job at least in getting ridding of the biggest
offender -- interupt overload. Also with NAPI also having got rid of
intermidiate queues to the socket level, facilitating of zero copy receive
should be relatively easy to add but there are no capable NICs in
existence (well, ok not counting the TIGONII/acenic that you can hack
and the fact that the tigon 2 is EOL doesnt help other than just for
experiments). I dont think theres any NIC that can offload reassembly;
that might not be such a bad idea.

Are you still continuing work on this?

cheers,
jamal
