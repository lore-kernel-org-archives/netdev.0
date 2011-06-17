From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: Netconf2011 slides...
Date: Fri, 17 Jun 2011 14:09:47 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B911E6EF96@nsmail.netscout.com>
References: <20110615.145937.1748734114172641662.davem@davemloft.net> <4DF9D644.708@linux.vnet.ibm.com> <BANLkTi=Vk__TbiGGrUkqexoJ1=mGh8a1gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Changli Gao" <xiaosuo@gmail.com>,
	"Srinivasa T N" <seenutn@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og107.obsmtp.com ([64.18.1.208]:48800 "HELO
	exprod6og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932104Ab1FQSQ6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 14:16:58 -0400
Content-class: urn:content-classes:message
In-Reply-To: <BANLkTi=Vk__TbiGGrUkqexoJ1=mGh8a1gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Changli Gao
> Sent: June 17, 2011 9:22 AM
> To: Srinivasa T N
> Cc: David Miller; netdev@vger.kernel.org
> Subject: Re: Netconf2011 slides...
>=20
> On Thu, Jun 16, 2011 at 6:09 PM, Srinivasa T N
> <seenutn@linux.vnet.ibm.com> wrote:
> > =A0 =A0 =A0 =A0Were there some interesting topics which is useful f=
or the
> community?
> > (Few lines on each such topic would do).
> >
>=20
> netmap was mentioned by Tom. It is interesting for me.
>=20
> http://info.iet.unipi.it/~luigi/netmap/

http://lists.openwall.net/netdev/2011/06/08/7

Just curious is there anything that we can do to enhance TPACKET_V3 (ig=
nore the memcpy)?
Not selling it because I have proposed the patch but anyone who is seri=
ous
about online/offline packet mining for multiple ports would have hard t=
ime scaling with
tpacket_v1[2] to begin with.

At the very least, one needs block abstraction + timeout mechanism. Sim=
ple.
One just can't retire data - packet-by-packet. We have boxes capable
of mining ~40G with similar approach.

Now we can also think about rolling it into a separate driver but then =
that's
something that is open for discussion.

Benefits of a driver are as follows:
1) Folks can customize block/packet headers according to their needs wi=
thout having to recompile the kernel.
2) No core network bloat.
3) Smaller NPU/FPGA shops can churn out a new driver patchset relativel=
y quickly.



>=20
> --
> Regards,
> Changli Gao(xiaosuo@gmail.com)

Regards
Chetan Loke

