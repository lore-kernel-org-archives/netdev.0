From: Troy Wilson <tcw@tempest.prismnet.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 5 Sep 2002 17:11:15 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209052211.g85MBFdm099387@tempest.prismnet.com>
References: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
 "from jamal at Sep 5, 2002 04:59:47 pm"
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> So if i understood correctly (looking at the intel site) the main value
> add of this feature is probably in having the CPU avoid reassembling and
> retransmitting.

Quoting David S. Miller:

dsm> The performance improvement comes from the fact that the card
dsm> is given huge 64K packets, then the card (using the given ip/tcp
dsm> headers as a template) spits out 1500 byte mtu sized packets.
dsm> 
dsm> Less data DMA'd to the device per normal-mtu packet and less
dsm> per-packet data structure work by the cpu is where the improvement
dsm> comes from.


> Do you have any stats from the hardware that could show
> retransmits etc;

  I'll gather netstat -s after runs with and without TSO enabled.
Anything else you'd like to see?


> have you tested this with zero copy as well (sendfile)

  Yes.  My webserver is Apache 2.0.36, which uses sendfile for anything
over 8k in size.  But, iirc, Apache sends the http headers using writev.

Thanks,

- Troy
