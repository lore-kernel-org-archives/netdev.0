From: Giuliano Pochini <pochini@shiny.it>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 10:23:59 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <XFMail.20040422102359.pochini@shiny.it>
References: <20040421132047.026ab7f2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        cfriesen@nortelnetworks.com,
        =?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040421132047.026ab7f2.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 21-Apr-2004 David S. Miller wrote:
> On Wed, 21 Apr 2004 19:03:40 +0200
> J=F6rn Engel <joern@wohnheim.fh-wedel.de> wrote:
>=20
>> Heise.de made it appear, as if the only news was that with tcp
>> windows, the propability of guessing the right sequence number is not
>> 1:2^32 but something smaller.  They said that 64k packets would be
>> enough, so guess what the window will be.
>
> Yes, that is their major discovery.  You need to guess the ports
> and source/destination addresses as well, which is why I don't
> consider this such a serious issue personally.

Yes, but it is possible, expecially for long sessions. Also,
data injections is also possible with the same method, because
the receiver accepts everything inside the window, which is
usually 64k. Out of curiosity: in case Linux receives two
packets relative to the same portion of the stream, does it
check if the overlapping data is the same ? It would add extra
security about data injection in case the data has not been
sent to userspace yet.


--
Giuliano.
