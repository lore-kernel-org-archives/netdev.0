From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 23:27:45 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712192209470.26514@kivilampi-30.cs.helsinki.fi>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>
 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
 <4768123A.7040603@cosmosbay.com>  <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
  <47682F8C.20205@cosmosbay.com>  <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
  <47694FCC.1020507@cosmosbay.com> <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
 <47695CEF.4090908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-317292208-1198095529=:26514"
Cc: Jan Engelhardt <jengelh@computergmbh.de>,
	Eric Dumazet <dada1@cosmosbay.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42614 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXLSV1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 16:27:47 -0500
In-Reply-To: <47695CEF.4090908@cosmosbay.com>
Content-ID: <Pine.LNX.4.64.0712192323110.27945@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-317292208-1198095529=:26514
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712192321481.27945@kivilampi-30.cs.helsinki.fi>

On Wed, 19 Dec 2007, Eric Dumazet wrote:

> James Nichols a écrit :
> > On 12/19/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> > > James Nichols a écrit :
> > > > > So you see outgoing SYN packets, but no SYN replies coming from the
> > > > > remote
> > > > > peer ?  (you mention ACKS, but the first packet received from the
> > > > > remote
> > > > >  peer should be a SYN+ACK),
> > > > Right, I meant to say SYN+ACK.  I don't see them coming back.
> > > So... Really unlikely a linux problem, but ...
> > >
> > 
> > 
> > I don't know how you can be so sure.  Turning tcp_sack off instantly
> > resovles the problem and all connections are succesful.  I can't
> > imagine even the most far-fetched scenario where a router or every
> > single remote endpoints would suddenly stop causing the problem just
> > by removing a single TCP option.

You could also check if you can pull same trick off by touching 
tcp_timestamps. It affects the TCP header as well.



-- 
 i.
---696243703-317292208-1198095529=:26514--
