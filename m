From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: Stable inclusion request: recvmsg/sendmsg userspace regression
 fix
Date: Wed, 18 Feb 2015 15:37:43 +0000
Message-ID: <20150218153743.GB1922@charon>
References: <54CBA338.1000207@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ani Sinha <ani@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stable Tree <stable@vger.kernel.org>
To: Michal Marek <mmarek@suse.cz>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54CBA338.1000207@suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 04:28:56PM +0100, Michal Marek wrote:
> Hi,
>=20
> please include
>=20
> commit 6a2a2b3ae0759843b22c929881cc184b00cc63ff
> Author: Ani Sinha <ani@arista.com>
> Date:   Mon Sep 8 14:49:59 2014 -0700
>=20
>     net:socket: set msg_namelen to 0 if msg_name is passed as NULL in
> msghdr struct from userland.
>=20
> to 3.14.y and older trees, since it fixes a userspace regression caus=
ed
> by commit dbb490b9 ("net: socket: error on a negative msg_namelen"). =
The
> patch applies cleanly to all trees down to 2.6.32.y.
>=20

I'm queuing this for the 3.16 kernel as well.  Thanks!

Cheers,
--
Lu=EDs

> Thanks,
> Michal
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
