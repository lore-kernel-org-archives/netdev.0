From: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 08:55:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005201c366e8$0a422a20$c801a8c0@llewella>
References: <20030728213933.F81299@coredump.scriptkiddie.org> <200308171509570955.003E4FEC@192.168.128.16> <200308171516090038.0043F977@192.168.128.16> <1061127715.21885.35.camel@dhcp23.swansea.linux.org.uk> <200308171555280781.0067FB36@192.168.128.16> <1061134091.21886.40.camel@dhcp23.swansea.linux.org.uk> <200308171759540391.00AA8CAB@192.168.128.16> <1061137577.21885.50.camel@dhcp23.swansea.linux.org.uk> <200308171827130739.00C3905F@192.168.128.16> <1061141045.21885.74.camel@dhcp23.swansea.linux.org.uk> <20030817224849.GB734@alpha.home.local> <20030817223118.3cbc497c.davem@redhat.com> <20030818133957.3d3d51d2.skraw@ithnet.com> <20030818044419.0bc24d14.davem@redhat.com> <20030818143401.1352d158.skraw@ithnet.com> <20030818053007.7852ca77.davem@redhat.com> <20030818145316.3a81f70c.skraw@ithnet.com> <20030818055555.248f2a01.davem@redhat.com> <1061213027.16017.2220.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Stephan von Krawczynski" <skraw@ithnet.com>, <willy@w.ods.org>,
   <alan@lxorguk.ukuu.org.uk>, <carlosev@newipnet.com>,
   <lamont@scriptkiddie.org>, <davidsen@tmr.com>, <marcelo@conectiva.com.br>,
   <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>, <layes@loran.com>,
   <torvalds@osdl.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Under Linux, by default, IP addresses are owned by the system
> > not by interfaces.
>
> Folks, the above is the punch line. I am just going over all emails on
> this thread and i see this point being missed.
> People are quoting tons of RFCs while the really important point being
> missed is the above line.

If that is true, then source routing would not work either: it would just
route it back to the host, select the next hop, and choose based on
destination routing tables. There would be no way to know which IP address
is bound to which interface.
If that is true, then then having multiple network interfaces on a segment
would in effect mean that you have one IP address on multiple interfaces. As
Alan mentioned that is an illegal configuration.
If that is true, seperation of firewall interfaces is impossible.

All of which isn't the case.

I'll let it rest for now. I don't think quoting rfc's, pointing out that it
doesn't confirm to any reference implementation of IP, or any argument are
going to help. This is not a case where technical merits win. This is
politics. I don't care anymore.

Regards,
Bas
