From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Sun, 15 Feb 2004 09:03:20 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402150901460.12324-100000@thoron.boston.redhat.com>
References: <402F76C2.6030300@kolumbus.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <402F76C2.6030300@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:

> skb_checksum_help() updates skb->ip_summed to CHECKSUM_NONE in the=20
> original skb, and this should be seen by the driver. With your change=20
> the checksum is calculated twice, once for the looping back packet, and=
=20
> once for the outgoing.

[Looks like my posts are not making it to netdev]

It updates ip_summed in the cloned packet header, but not in the original=
=20
packet, which gets sent to the driver with an already completed checksum.

See the original post.


- James
--=20
James Morris
<jmorris@redhat.com>
