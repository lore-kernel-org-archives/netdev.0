From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH net-next 1/2] net: filter: split filter.c into two files
Date: Thu, 24 Jul 2014 19:45:02 -0400
Message-ID: <39107.1406245502@turing-police.cc.vt.edu>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
            <1406095319-3627-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1406245502_23260P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:59972 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbaGXXqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 19:46:13 -0400
In-Reply-To: Your message of "Tue, 22 Jul 2014 23:01:58 -0700."
             <1406095319-3627-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1406245502_23260P
Content-Type: text/plain; charset=us-ascii

On Tue, 22 Jul 2014 23:01:58 -0700, Alexei Starovoitov said:
> BPF is used in several kernel components. This split creates logical boundary
> between generic eBPF core and the rest
>
> kernel/bpf/core.c: eBPF interpreter
>
> net/core/filter.c: classic->eBPF converter, classic verifiers, socket filters
>
> This patch only moves functions.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  kernel/Makefile     |    1 +
>  kernel/bpf/Makefile |    1 +
>  kernel/bpf/core.c   |  536 +++++++++++++++++++++++++++++++++++++++++++++++++
++
>  net/core/filter.c   |  511 ------------------------------------------------
>  4 files changed, 538 insertions(+), 511 deletions(-)
>  create mode 100644 kernel/bpf/Makefile
>  create mode 100644 kernel/bpf/core.c
>
> diff --git a/kernel/Makefile b/kernel/Makefile
> index f2a8b6246ce9..e7360b7c2c0e 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -87,6 +87,7 @@ obj-$(CONFIG_RING_BUFFER) += trace/
>  obj-$(CONFIG_TRACEPOINTS) += trace/
>  obj-$(CONFIG_IRQ_WORK) += irq_work.o
>  obj-$(CONFIG_CPU_PM) += cpu_pm.o
> +obj-$(CONFIG_NET) += bpf/

I was expecting to see CONFIG_NETFILTER here.  Is CONFIG_NET intentional?

--==_Exmh_1406245502_23260P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBU9GafQdmEQWDXROgAQJlwg/8Dg5Sy72kB44khL+t/7LTkAmesCSLNJIi
UnKDb5zfsR30dTOAwe6KleEwBK1JoBov4gHdka4D8LBUp8Pt3ixrv/2svXe8oM78
A01nDp+gT8FNuNE1PvCufEdrw2UGCvWHo1/rOXbRbsCyJPEt9ZKxfw8lkVojS+Qc
D7lfQ4cKkzcOFk0JUrSAFiCBpaOuv+IsTNtq006+hs0QPtxjntv9YbAH7KJ0yCEw
89ScoK4yBfvY4sEYeC+t7ziuhwgggMVvweec1X41MuzNCnoxCYcqtZaWKemdP+U/
xHLgwTKIHFznlmzddQ93mZgzdgdcVJ3zCPHAOuAgghVW85VnVTCzS/arr3iQaSHP
kgRCddAcfWyFQxIK+VkT7A2+mzuKEO4ja7tABskY9D+vRD1oWgncvpIB8kPQfEDW
+eCT32u7zmPfa+86bnHpxUtjHIQhTDsfGeId1QLF2GBtztTbOz2SqgbQ9+RUUI3m
E4D4mmdf6Pn4kGtvlAoj+AZSFs3+A0osjqTwKECg7MctIDht87IZ9HAWBZBpDFWU
fD1ZJKc4SGU4L/Furf2GntenoYALk376ZukFYroMgYoPpVwyZeYa3wAxor+GTCvB
Pru0dHZEMMoG502xzE4H3Oh02qc0Xh7gNfe4TZ2rTieOHzBk72Lxati/b3t5kjec
zIJe3qe/oQI=
=k/IB
-----END PGP SIGNATURE-----

--==_Exmh_1406245502_23260P--
