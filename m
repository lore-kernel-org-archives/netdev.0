From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Mon, 16 Feb 2004 08:45:47 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402160843570.15855-100000@thoron.boston.redhat.com>
References: <403066A2.30705@kolumbus.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <403066A2.30705@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Feb 2004, Mika Penttil=E4 wrote:

> James Morris wrote:
>=20
> >No, it's not needed by all callers, and is just a does-one-thing helpe=
r=20
> >function.
> >
> >
> It is needed for cloned skbs, so check for this should go in=20
> skb_checksum_help().

No, there is no need to bloat a simple helper function out with this=20
(and then need to handle OOM internally etc.), and it is not appropriate=20
for all callers.

- James
--=20
James Morris
<jmorris@redhat.com>
