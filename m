From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Fri, 8 Nov 2002 06:30:53 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211080626160.14675-100000@shell.cyberus.ca>
References: <3DCAF76A.9080409@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCAF76A.9080409@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 7 Nov 2002, Ben Greear wrote:

> Any ideas for what to try next?  What about upping the skb-hotlist to
> 1024 or so?  Maybe also pre-load it with buffers to make it less likely we'll
> run low?  (Rx-Drops means it could not allocate a buffer, right?)
>

You seem to be using that patch of yours where you route to yourself?
Well, since you are up for it:
- try with two ports only; eth0->eth1 and vary then vary RX ring
{32, 64,128,256,512,1024}
- send at least 1 minute worth of data at wire rate
a) small packets 64 bytes
b) repeat with MTU sized packets

Repeat above with eth0->eth1, eth2->eth3

also try where machine is a router and you have a source/sink host

cheers,
jamal
