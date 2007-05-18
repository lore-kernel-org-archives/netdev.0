From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited Slow-Start)
Date: Fri, 18 May 2007 20:42:28 +0300
Message-ID: <464DE584.7030008@ev-en.org>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:64003
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbXERSTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 14:19:45 -0400
In-Reply-To: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
>=20
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/n=
etworking/ip-sysctl.txt
> index ce16e6a..44ba8d4 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -239,6 +239,19 @@ tcp_max_orphans - INTEGER
>  	more aggressively. Let me to remind again: each orphan eats
>  	up to ~64K of unswappable memory.
> =20
> +tcp_max_ssthresh - INTEGER
> +	Limited Slow-Start for TCP with Large Congestion Windows defined in
> +	RFC3742. Limited slow-start is a mechanism to limit grow of the

s/grow/growth/

> +	congestion window on the region where congestion window is larger t=
han
> +	tcp_max_ssthresh. A TCP connection with a large congestion window c=
ould
> +	have its congestion window increased by thousand (or even more)
> +	segments per RTT by the traditional slow-start procedure which migh=
t be
> +	counter-productive to TCP performance when packet losses start to
> +	occur. With limited slow-start TCP increments congestion window at
> +	most tcp_max_ssthresh/2 segments per RTT when the congestion window=
 is

I'm not a native English speaker but "at most" sounds a bit awkward to
me, maybe change it to "by no more than". But I'm sure someone can find
a better phrasing.

Baruch
