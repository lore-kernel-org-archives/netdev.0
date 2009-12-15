From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add initrwnd to iproute2
Date: Tue, 15 Dec 2009 23:37:58 +0100
Message-ID: <4B280FC6.7060003@gmail.com>
References: <pvmws0nricn.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, therber@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42591 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbZLOWiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 17:38:08 -0500
In-Reply-To: <pvmws0nricn.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/12/2009 23:19, chavey@google.com a =E9crit :
> Add initrwnd option parsing to iproute. This option uses the new
> rtnetlink init_rcvwnd to set the TCP initial receive window size
> advertised by passive and active TCP connections.
>=20
> Signed-off-by: Laurent Chavey <chavey@google.com>
> --
>  doc/ip-cref.tex           |    5 +++++
>  include/linux/rtnetlink.h |    2 ++
>  ip/iproute.c              |   13 ++++++++++++-
>  3 files changed, 19 insertions(+), 1 deletions(-)
>=20
> diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
> index bb4eb78..30503c7 100644
> --- a/doc/ip-cref.tex
> +++ b/doc/ip-cref.tex
> @@ -1324,7 +1324,12 @@ peers are allowed to send to us.
>      If it is not given, Linux uses the value selected with \verb|sys=
ctl|
>      variable \verb|net/ipv4/tcp_reordering|.
> =20
> +\item \verb|initrwnd NUMBER|
> =20
> +--- [2.5.70+ only] Initial receive window size for connections to=20
> +    this destination. The actual window size is this value multiplie=
d
> +    by the MSS (''Maximal Segment Size'') of the connection. The def=
ault
> +    value is zero, meaning to use Slow Start value.
> =20

Maybe its true with google custom kernels, but for upstream, this is 2.=
6.33+ :)
