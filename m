From: James Morris <jmorris@redhat.com>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Wed, 21 Apr 2004 20:45:42 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0404212042540.20483-100000@thoron.boston.redhat.com>
References: <20040421132047.026ab7f2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>,
        <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040421132047.026ab7f2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2004, David S. Miller wrote:

> On Wed, 21 Apr 2004 19:03:40 +0200
> J=F6rn Engel <joern@wohnheim.fh-wedel.de> wrote:
>=20
> > Heise.de made it appear, as if the only news was that with tcp
> > windows, the propability of guessing the right sequence number is not
> > 1:2^32 but something smaller.  They said that 64k packets would be
> > enough, so guess what the window will be.
>=20
> Yes, that is their major discovery.  You need to guess the ports
> and source/destination addresses as well, which is why I don't
> consider this such a serious issue personally.
>
> It is mitigated if timestamps are enabled, because that becomes
> another number you have to guess.
>=20
> It is mitigated also by randomized ephemeral port selection, which
> OpenBSD implements and we could easily implement as well.

What about the techniques mentioned in
http://www.ietf.org/internet-drafts/draft-ietf-tcpm-tcpsecure-00.txt ?

Curiously there is no mention of port guessing or timestamps there.


- James
--=20
James Morris
<jmorris@redhat.com>
