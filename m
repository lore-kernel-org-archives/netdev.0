From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu,  5 Sep 2002 15:48:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031266115.3d77df4344463@imap.linux.ibm.com>
References: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Troy Wilson <tcw@tempest.prismnet.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting jamal <hadi@cyberus.ca>:

> So if i understood correctly (looking at the intel site) the main
> value add of this feature is probably in having the CPU avoid
> reassembling and retransmitting. I am willing to bet that the real

Er, even just assembling and transmitting? I'm thinking of the
reduction in things like separate memory allocation calls and looking
up the route, etc..??

> value in your results is in saving on retransmits; I would think
> shoving the data down the NIC and avoid the fragmentation shouldnt
> give you that much significant CPU savings. Do you have any stats

Why do say that? Wouldnt the fact that youre now reducing the
number of calls down the stack by a significant number provide
a significant saving? 

> from the hardware that could show retransmits etc; have you tested
> this with zero copy as well (sendfile) again, if i am right you
> shouldnt see much benefit from that either?

thanks,
Nivedita
