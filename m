From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Fri, 10 Oct 2008 10:10:22 +0200
Message-ID: <20081010081022.GA27187@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <200810091921.04230.rdenis@simphalempin.com> <20081009214224.GD21013@1wt.eu> <200810101059.25904.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4692 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755333AbYJJIKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 04:10:25 -0400
Content-Disposition: inline
In-Reply-To: <200810101059.25904.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 10:59:25AM +0300, R=E9mi Denis-Courmont wrote:
> On Friday 10 October 2008 00:42:24 ext Willy Tarreau, you wrote:
> > On Thu, Oct 09, 2008 at 07:21:03PM +0300, R=E9mi Denis-Courmont wro=
te:
> > > Le mercredi 8 octobre 2008 14:54:02 Stephen Hemminger, vous avez =
=E9crit=A0:
> > > > Does this break NAT traversal via STUNT used by applications li=
ke
> > > > Skype?
> > >
> > > This will break the main ICE-TCP mechanism (IETF
> > > draft-ietf-mmusic-ice-tcp). I am not aware of any application usi=
ng this
> > > _as_of_now_. Probably too many NAT and firewall implementations w=
ill
> > > reject it already. And then, some TCP stacks reportedly do not su=
pport it
> > > (e.g. Windows before Vista).
> >
> > And opening this through firewalls would be too much dangerous as i=
t would
> > allow servers to reconnect outside, pretty much defeating the initi=
al
> > purpose of the firewall.
>=20
> Duh? If you require a SYN from the outside to the server, before you =
allow the=20
> server to send either SYN or SYN/ACK, I fail to see the problem.

Requiring the firewall to expect a first SYN to come from the internet =
is like
doing no check at all. When your server has been rooted, you can pretty=
 much
expect that your guest has no problem sending you a SYN.

Willy

