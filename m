From: Miika Komu <miika@iki.fi>
Subject: Re: [Infrahip] [PATCH] Host Identity Protocol
Date: Tue, 22 Mar 2005 16:08:31 +0200 (EET)
Message-ID: <Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi>
References: <42369919.9010203@cs.helsinki.fi> <Pine.GSO.4.58.0503201805240.1521@kekkonen.cs.hut.fi>
 <20050321.024241.67451836.yoshfuji@linux-ipv6.org> <20050320200356.5f8fa583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: yoshfuji@linux-ipv6.org, Andrei Gurtov <gurtov@cs.helsinki.fi>,
        netdev@oss.sgi.com, infrahip@hiit.fi
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050320200356.5f8fa583.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Mar 2005, David S. Miller wrote:

> On Mon, 21 Mar 2005 02:42:41 +0900 (JST)
> YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> =
wrote:
>
> > However, all signaling should be handled in userspace as we (will) do
> > for MIP6.
>
> Yes, I've been telling them similarly in a private
> email discussion.  I'm very glad someone else says
> this too, so I don't appear as the only person who
> feels this way :-)

Thank you, David and Yoshifugi, for your feedback. Please accept my
apologies for my late response.

I am having difficulties in digesting the counterarguments against the
kernel based approach because of the lack of detailed reasoning and
ambiguities. Yes, MIP6 and IKE signalling is handled in the userspace, bu=
t
the same is not true for SCTP (lksctp). At the same time, Linux is a
monolithic kernel instead of microkernel architecture. Finally, good
engineering practise is to put everything in the userspace, unless there
is good reason for putting it in to the kernelspace.

We don't currently have concrete measurements (comparing userspace and
kernelspace approaches) to justify our kernel oriented approach, so we
will have to get back to you later with some figures. If the results show
that an userspace implementation is superior to a kernel based approach i=
n
terms of security or performance, we may have rewrite the code to the
userspace. In the mean time, do you happen to know any good references
where any userspace network protocol implementation has been compared and
measured against a kernelspace implementation? It would be a good startin=
g
point for us.

I would like to mention that lksctp was implemented in the 2.6 kernel
because of better performance and tighter integration to the socket API.
We are dealing with similar issues with HIPL but seems like we need to
justify the reasons by analyzing and measuring. In addition, security
issues (DoS protection, user supplied public keys, etc) are taken pretty
seriously in HIP and may benefit from a kernel oriented approach.

--=20
Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
