From: jamal <hadi@cyberus.ca>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 5 Sep 2002 16:59:47 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
References: <200209051830.g85IUMdH096254@tempest.prismnet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Troy Wilson <tcw@tempest.prismnet.com>
In-Reply-To: <200209051830.g85IUMdH096254@tempest.prismnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hey, thanks for crossposting to netdev

So if i understood correctly (looking at the intel site) the main value
add of this feature is probably in having the CPU avoid reassembling and
retransmitting. I am willing to bet that the real value in your results is
in saving on retransmits; I would think shoving the data down the NIC
and avoid the fragmentation shouldnt give you that much significant CPU
savings. Do you have any stats from the hardware that could show
retransmits etc; have you tested this with zero copy as well (sendfile)
again, if i am right you shouldnt see much benefit from that either?

I would think it probably works well with things like partial ACKs too?
(I am almost sure it does or someone needs to be spanked, so just
checking).

cheers,
jamal
