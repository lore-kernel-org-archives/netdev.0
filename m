From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Thu, 10 Dec 2009 16:31:30 +0100
Message-ID: <4B211452.40600@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	<4B1F0151.10903@gmail.com> <20091208180801.88be28ba.akpm@linux-foundation.org> <4B20FC2E.7050809@gmail.com> <4B2102B4.7050702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60609 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760801AbZLJPbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 10:31:32 -0500
In-Reply-To: <4B2102B4.7050702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 15:16, William Allen Simpson a =E9crit :
> Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree
>=20
> Remove the offending code, and replace with comments.  This is an
> unlikely problem, so depend on human finding any future error.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  net/ipv4/tcp.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)

This is not necessary, David already _did_ the thing, and _told_ so.


You probably missed fact we are in merge window, so fixes (and only fix=
es)
are pushed into net-2.6 tree.

When Linus closes this merge window (issuing a linux-2.6.33-rc1 tag),
then David re-opens net-next-2.6 tree for new stuff.

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
itdiff;h=3D3dc789320e1b310cb505dcd94512c279abcd5e1c

commit 3dc789320e1b310cb505dcd94512c279abcd5e1c
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Dec 8 20:07:54 2009 -0800

    tcp: Remove runtime check that can never be true.

    GCC even warns about it, as reported by Andrew Morton:

    net/ipv4/tcp.c: In function 'do_tcp_getsockopt':
    net/ipv4/tcp.c:2544: warning: comparison is always false due to lim=
ited range of data type

    Signed-off-by: David S. Miller <davem@davemloft.net>





