From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <rdenis@simphalempin.com>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Fri, 10 Oct 2008 10:59:25 +0300
Message-ID: <200810101059.25904.rdenis@simphalempin.com>
References: <20081008081109.GA25342@1wt.eu> <200810091921.04230.rdenis@simphalempin.com> <20081009214224.GD21013@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "ext Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40186 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbYJJH7a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 03:59:30 -0400
In-Reply-To: <20081009214224.GD21013@1wt.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 10 October 2008 00:42:24 ext Willy Tarreau, you wrote:
> On Thu, Oct 09, 2008 at 07:21:03PM +0300, R=E9mi Denis-Courmont wrote=
:
> > Le mercredi 8 octobre 2008 14:54:02 Stephen Hemminger, vous avez =E9=
crit=A0:
> > > Does this break NAT traversal via STUNT used by applications like
> > > Skype?
> >
> > This will break the main ICE-TCP mechanism (IETF
> > draft-ietf-mmusic-ice-tcp). I am not aware of any application using=
 this
> > _as_of_now_. Probably too many NAT and firewall implementations wil=
l
> > reject it already. And then, some TCP stacks reportedly do not supp=
ort it
> > (e.g. Windows before Vista).
>
> And opening this through firewalls would be too much dangerous as it =
would
> allow servers to reconnect outside, pretty much defeating the initial
> purpose of the firewall.

Duh? If you require a SYN from the outside to the server, before you al=
low the=20
server to send either SYN or SYN/ACK, I fail to see the problem.

> > On the other hand, if someone were to tunnel/encapsulate TCP over U=
DP,
> > this could actually be useful - think about peer-to-peer NATted-to-=
NATted
> > file transfers for instance.
>
> This is already possible using netcat. You can force both ports. It h=
as no
> flow control but would be enough to chat or transfer small config fil=
es.

=46iles transfer over UDP? Come on. I won't restart the UDP sendfile di=
scussion.

--=20
R=E9mi Denis-Courmont
