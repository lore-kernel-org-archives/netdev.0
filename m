From: Andreas Messer <andi@bastelmap.de>
Subject: Re: Unexpected tcpv6 connection resets since linux 4.4
Date: Wed, 09 Mar 2016 20:12:34 +0100
Message-ID: <2277643.Q5Ry2PpJQt@proton>
References: <4875526.tAzumr2zO3@proton> <CAM_iQpXSu_uXCOCtw02EAaOVP_54a1G8pgZrDMTWFEGnSeycJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart10649902.Q3VEA1Nnz0"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXSu_uXCOCtw02EAaOVP_54a1G8pgZrDMTWFEGnSeycJQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nextPart10649902.Q3VEA1Nnz0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

On Mon, Mar 7, 2016 at 15:58, Cong Wang <xiyou.wangcong@gmail.com>wrote:
> On Sun, Mar 6, 2016 at 7:10 AM, Andreas Messer <andi@bastelmap.de> wrote:
> > i have updated two of my machines in the last weeks to linux 4.4.1 and
> > linux 4.4.3. It seems that since then i get unexpected TCPv6 connection
> > resets when connecting to these machines remotely. The issue occurs with
> > sshd and with a http service. /etc/hosts.deny and /etc/hosts.allow are
> > empty on both server machines. I'm not so in IPv6 and have no idea whats
> > going on. Please find attached a network trace from one of the machines
> > when connecting with ssh (on port 23 for debugging).
> 
> Sounds like the problem fixed by the following commit:
> 
> commit 9cf7490360bf2c46a16b7525f899e4970c5fc144
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Feb 2 19:31:12 2016 -0800
> 
>     tcp: do not drop syn_recv on all icmp reports

Thanks for the tip. I applied the patch to V4,4,1 and it solved the problem.

Cheers,
Andreas

--nextPart10649902.Q3VEA1Nnz0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlbgdakACgkQkLO6qowrr1F7wQCg2AU21JNW7Ov4JRCBXQZkYVvm
OiIAnicH4xCjPCvyjNwnXfJ9jtzSBnKF
=oigy
-----END PGP SIGNATURE-----

--nextPart10649902.Q3VEA1Nnz0--
