From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Sun, 15 Feb 2004 20:50:04 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402152048510.14031-100000@thoron.boston.redhat.com>
References: <402F97B4.4010107@kolumbus.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <402F97B4.4010107@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:

> ah, sorry, I see your point now. Maybe this copy should be in=20
> skb_checksum_help() ?

No, it's not needed by all callers, and is just a does-one-thing helper=20
function.


- James
--=20
James Morris
<jmorris@redhat.com>
