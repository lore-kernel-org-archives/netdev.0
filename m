From: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 17 Aug 2003 15:59:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <00fa01c364c7$e2c6ba50$c801a8c0@llewella>
References: <Pine.LNX.3.96.1030728222606.21100A-100000@gatekeeper.tmr.com> <20030728213933.F81299@coredump.scriptkiddie.org> <200308171509570955.003E4FEC@192.168.128.16> <200308171516090038.0043F977@192.168.128.16> <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Lamont Granquist" <lamont@scriptkiddie.org>,
   "Bill Davidsen" <davidsen@tmr.com>, "David S. Miller" <davem@redhat.com>,
   "Marcelo Tosatti" <marcelo@conectiva.com.br>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>, <layes@loran.com>, <torvalds@osdl.org>,
   "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
   "Carlos Velasco" <carlosev@newipnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Proxy ARP only.
>
> >    A.3.  ARP datagram
> >
> >       An ARP reply is discarded if the destination IP address does not
> >       match the local host address.
>
> Linux counts all the IP addresses it has as being local host address.
>
> And Linux btw has arpfilter which can do far more than just imitate your
> favourite network religion of the week
>

I think the whole mess comes from the ambigious use of the word host in RFC
826, and several possible interpretations. It can mean both ethernet host
(i.e. a NIC) or internet host (i.e. the whole server). This isn't clear from
the RFC. In fact, the meanings are mixed. It's not a good RFC.

The linux way is a perfectly legal, if somewhat awkward, way to interpret
the RFC. Me too, I'd like a device respond only to ARP requests that are
meant for an IP bound to it, but please, let's not turn this into a holy
war.

Regards,
Bas
