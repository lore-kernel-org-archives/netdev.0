From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add somaxconn to Documentation/sysctl/net.txt
Date: Tue, 13 Apr 2010 20:40:12 +0200
Message-ID: <1271184012.16881.549.camel@edumazet-laptop>
References: <201004131325.29104.rob@landley.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Rob Landley <rob@landley.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:42208 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab0DMSkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 14:40:18 -0400
In-Reply-To: <201004131325.29104.rob@landley.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 13:25 -0500, Rob Landley a =C3=A9crit :
> From: Rob Landley <rob@landley.net>
>=20
> Add somaxconn to Documentation/sysctl/net.txt
>=20
> Signed-off-by: Rob Landley <rob@landley.net>
> ---
>=20
>  Documentation/sysctl/net.txt |    6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.=
txt
> index df38ef0..2740085 100644
> --- a/Documentation/sysctl/net.txt
> +++ b/Documentation/sysctl/net.txt
> @@ -90,6 +90,12 @@ optmem_max
>  Maximum ancillary buffer size allowed per socket. Ancillary data is =
a sequence
>  of struct cmsghdr structures with appended data.
> =20
> +somaxconn
> +---------
> +
> +Maximum backlog of unanswered connections for a listening socket.  P=
rovides
> +an upper bound on the "backlog" parameter of the listen() syscall.
> +
>  2. /proc/sys/net/unix - Parameters for Unix domain sockets
>  -------------------------------------------------------
> =20
>=20

Please cc netdev for such patches

Extract of Documentation/networking/ip-sysctl.txt

somaxconn - INTEGER
	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
	Defaults to 128.  See also tcp_max_syn_backlog for additional tuning
	for TCP sockets.

I guess you need to change both files ?


