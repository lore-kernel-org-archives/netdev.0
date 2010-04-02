From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Receive steering and hash and cache misses
Date: Fri, 2 Apr 2010 11:54:39 -0700
Message-ID: <20100402115439.348575c9@nehalam>
References: <20100402102650.5bdb5b52@nehalam>
	<g2l65634d661004021059z94214a43v82409d15a0fb09b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47008 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab0DBTBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 15:01:04 -0400
In-Reply-To: <g2l65634d661004021059z94214a43v82409d15a0fb09b6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Apr 2010 10:59:43 -0700
Tom Herbert <therbert@google.com> wrote:

> On Fri, Apr 2, 2010 at 10:26 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> >
> > Although Receive Packet Steering can use a hardware generated recei=
ve hash
> > the device driver still causes an unnecessary cache miss on the int=
errupt
> > processing CPU. =C2=A0The current Ethernet network device driver re=
ceive processing
> > has the device driver calling eth_type_trans() which causes a the
> > interrupt CPU to read the received frame header.
> >
>=20
> It should be possible to deduce the values set by eth_type_trans from
> the RX descriptor along with the RX hash.  I'll post the patch gettin=
g
> rxhash from bnx2x which does this.
>=20

On sky2, I get only RSS, Checksum, and length from descriptor info.
