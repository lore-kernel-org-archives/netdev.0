From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] tc-sfq: update man page
Date: Tue, 31 Jan 2012 16:28:00 +0100
Message-ID: <1328023680.2297.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327411778.7231.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F27E0C4.1050609@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53253 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab2AaP2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 10:28:04 -0500
Received: by bkcjm19 with SMTP id jm19so60241bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 07:28:03 -0800 (PST)
In-Reply-To: <4F27E0C4.1050609@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 13:38 +0100, Jan Ceuleers a =C3=A9crit =
:
> On 01/24/2012 02:29 PM, Eric Dumazet wrote:
> > Add documentation about RED mode, and new parameters (flows, depth)
> > added in linux 3.3
> >
> > Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> > ---
> >   man/man8/tc-sfq.8 |  127 +++++++++++++++++++++++++++++++++++++---=
----
> >   1 file changed, 108 insertions(+), 19 deletions(-)
> >
> > diff --git a/man/man8/tc-sfq.8 b/man/man8/tc-sfq.8
> > index e177f56..5a651ff 100644
> > --- a/man/man8/tc-sfq.8
> > +++ b/man/man8/tc-sfq.8
> ...
> +Source and Destination port
> >   .P
> >   If these are available. SFQ knows about ipv4 and ipv6 and also UD=
P, TCP and ESP.
> >   Packets with other protocols are hashed based on the 32bits repre=
sentation of their
> > -destination and the socket they belong to. A flow corresponds most=
ly to a TCP/IP
> > -connection.
> > +destination and source. A flow corresponds mostly to a TCP/IP conn=
ection.
>=20
> Don't understand this. Did you want to replace "connection" by=20
> "destination and source"? Do you mean that a "connection" is=20
> characterised by source and destination?
>=20
>=20

Packets of other protocol (so not UDP, not TCP...) are hashed based on
their source IP _and_ destination IP

Old documentation wrongly stated the hash was done only based on
destination IP.

Also we no longer uses 'local socket' since SFQ uses standard rxhash or
flow dissector.
