From: "David S. Miller" <davem@redhat.com>
Subject: Re: [CHECKER] 32 Memory Leaks on Error Paths
Date: Sat, 20 Sep 2003 00:58:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920005811.09f12e07.davem@redhat.com>
References: <200309160435.h8G4ZkQM009953@elaine4.Stanford.EDU>
	<20030916090748.GE27703@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: dychen@stanford.edu, linux-kernel@vger.kernel.org, mc@cs.stanford.edu,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20030916090748.GE27703@wohnheim.fh-wedel.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2003 11:07:48 +0200
J=F6rn Engel <joern@wohnheim.fh-wedel.de> wrote:

> Looks valid.  And since skb isn't really needed until after these
> returns, moving four lines down a bit fixes the problem.
>=20
> Davem, is this correct?

Nope, now you're leaking the route instead of the SKB :-)

I'll put the correct fix in.
