From: Ranjeet Shetye <ranjeet.shetye2@zultys.com>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 13:01:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082664092.9062.14.camel@ranjeet-pc2.zultys.com>
References: <40869267.30408@nortelnetworks.com>
	 <Pine.LNX.4.53.0404211153550.1169@chaos>
	 <4086A077.2000705@nortelnetworks.com>
	 <20040421170340.GB24201@wohnheim.fh-wedel.de>
	 <20040421132047.026ab7f2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040421132047.026ab7f2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-04-21 at 13:20, David S. Miller wrote:
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
>=20
> It is mitigated if timestamps are enabled, because that becomes
> another number you have to guess.
>=20
> It is mitigated also by randomized ephemeral port selection, which
> OpenBSD implements and we could easily implement as well.
>=20
> I'm very happy that OpenBSD checked in a fix for this a week or so
> ago and took some of the thunder out of this bogusly hyped announcement.

(Not the same issue, but interesting still, and its related)

Isn't this (http://www.lowth.com/cutter/) an application on the same
lines ? (but from the perspective of a person ON one of the two endpoint
machines, rather than a remote third party).

QUOTE

There is a feature of the TCP/IP protocol that we could use to good
effect here :- If a packet (other than an RST) is received on a
connection that has the wrong sequence number, then the host responds by
sending a corrective "ACK" packet back. This "ACK" reply is designed to
put the sequence numbers at both ends back into step - and allows the
protocol to retransmit packets that got lost. This is very nice for our
needs - if the firewall sends a packet that is "correct" in all respects
except for the sequence number, then the host very helpfully tells us
what should have been used. We can then use this information to build
the RST packet that will abort the connection.

END OF QUOTE

thanks,

--=20

Ranjeet Shetye
Senior Software Engineer
Zultys Technologies
Ranjeet dot Shetye2 at Zultys dot com
http://www.zultys.com/
=20
The views, opinions, and judgements expressed in this message are solely
those of the author. The message contents have not been reviewed or
approved by Zultys.
