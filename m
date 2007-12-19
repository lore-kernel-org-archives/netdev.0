From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 12:43:13 -0500
Message-ID: <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>
	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
	 <4768123A.7040603@cosmosbay.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Jan Engelhardt" <jengelh@computergmbh.de>,
	linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:34657 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbXLSRnP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 12:43:15 -0500
Received: by fg-out-1718.google.com with SMTP id e21so503389fga.17
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 09:43:13 -0800 (PST)
In-Reply-To: <47694FCC.1020507@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> James Nichols a =E9crit :
> >> So you see outgoing SYN packets, but no SYN replies coming from th=
e remote
> >> peer ?  (you mention ACKS, but the first packet received from the =
remote
> >>  peer should be a SYN+ACK),
> >
> > Right, I meant to say SYN+ACK.  I don't see them coming back.
>
> So... Really unlikely a linux problem, but ...
>


I don't know how you can be so sure.  Turning tcp_sack off instantly
resovles the problem and all connections are succesful.  I can't
imagine even the most far-fetched scenario where a router or every
single remote endpoints would suddenly stop causing the problem just
by removing a single TCP option.


> > I can take these captures and take a look at the results.
> > Unfortunately, I don't think I'll be able to make the captures
> > available to the general public.
>
> I dont understand, why dont you change IPs to mask them with 192.168.=
X.Y, or
> just ME, and peer1, peer2, peer...

I will see if I can do that, but it's major pain with 2000 hosts.
Plus, there is application data in the packets that I can't allow into
the public domain.  I really don't think I can pull it off... I
literally would have to go through our legal department.

>
> Random ideas :
>
> 1) Is your server behind a NET router or something ?

What's a NET router?  I am behind a Cisco router and a firewall, but
these network components have completely been replaced/rebuilt several
times in the 4+ years that we've had this problem.  I've looked at the
logs there and neither are doing anything other than passing the
traffic along.

> 2) Are you sure you are not using connection tracking, and hit a limi=
t on it ?

I'm using ip_conntrack, but the limit I have for max entries is 65K.
The most I've seen in there are a couple thousand- that was one of the
first things I monitored very closely.
