From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 12 Sep 2002 10:18:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031851117.3d80cc6d8c8e0@imap.linux.ibm.com>
References: <Pine.LNX.4.44.0209120119580.25406-100000@gp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, "hadi@cyberus.ca" <hadi@cyberus.ca>,
   "tcw@tempest.prismnet.com" <tcw@tempest.prismnet.com>,
   "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Todd Underwood <todd@osogrande.com>
In-Reply-To: <Pine.LNX.4.44.0209120119580.25406-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Todd Underwood <todd@osogrande.com>:

> sorry for the late reply.  catching up on kernel mail.

> the main different, though, is that general purpose kernel
> development still focussed on the improvements in *sending* speed.
> for real high performance networking, the improvements are necessary
> in *receiving* cpu utilization, in our estimation. 
> (see our analysis of interrupt overhead and the effect on receivers
> at gigabit speeds--i hope that this has become common understanding
> by now)

Some of that may be a byproduct of the "all the worlds' a webserver"
mindset - we are primarily focussed on the server side (aka
money side ;)), and there is some amount of automatic thinking that
this means we're going to be sending data and receiving small packets,
mostly acks) in return. There is much less emphasis given to solving
the problems on the other side (active connection scalability for 
instance), or other issues that manifest themselves as 
client side bottlenecks for most applications..

thanks,
Nivedita
