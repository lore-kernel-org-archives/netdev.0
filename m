From: jamal <hadi@cyberus.ca>
Subject: Re: bk16 changes to cbq
Date: 03 Jul 2004 20:03:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088899435.1039.650.camel@jzny.localdomain>
References: <1088861810.1039.298.camel@jzny.localdomain>
	 <20040703101646.52ae1e01.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040703101646.52ae1e01.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-07-03 at 13:16, David S. Miller wrote:
> On 03 Jul 2004 09:36:50 -0400

> The test is racy with drivers, on the very next line the
> driver could take a TX completion interrupt and unplug the
> queue invalidating the test entirely.

I could be wrong:
The only thing the tx complete can do is open up the device for
more packets to tx into the device... i.e !netif_queue_stopped(sch->dev)
is true in that specific case. 
Which would mean theres no race.

> If the test proves wrong, that's OK because we'll try again
> at the top level of packet queue dispatch.
> 
> There was a good explaination of Stephen's patch
> on netdev when he posted it.

Let me dig into the emails and get back.

cheers,
jamal
