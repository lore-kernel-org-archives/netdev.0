From: "David S. Miller" <davem@redhat.com>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Wed, 21 Apr 2004 13:20:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421132047.026ab7f2.davem@redhat.com>
References: <40869267.30408@nortelnetworks.com>
	<Pine.LNX.4.53.0404211153550.1169@chaos>
	<4086A077.2000705@nortelnetworks.com>
	<20040421170340.GB24201@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: cfriesen@nortelnetworks.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20040421170340.GB24201@wohnheim.fh-wedel.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2004 19:03:40 +0200
J=F6rn Engel <joern@wohnheim.fh-wedel.de> wrote:

> Heise.de made it appear, as if the only news was that with tcp
> windows, the propability of guessing the right sequence number is not
> 1:2^32 but something smaller.  They said that 64k packets would be
> enough, so guess what the window will be.

Yes, that is their major discovery.  You need to guess the ports
and source/destination addresses as well, which is why I don't
consider this such a serious issue personally.

It is mitigated if timestamps are enabled, because that becomes
another number you have to guess.

It is mitigated also by randomized ephemeral port selection, which
OpenBSD implements and we could easily implement as well.

I'm very happy that OpenBSD checked in a fix for this a week or so
ago and took some of the thunder out of this bogusly hyped announcement.
