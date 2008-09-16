From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 02/14] Phonet: add CONFIG_PHONET
Date: Tue, 16 Sep 2008 13:06:12 -0300
Message-ID: <20080916160612.GF8702@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33338 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127AbYIPQPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 12:15:15 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-2-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 16, 2008 at 06:08:02PM +0300, R=E9mi Denis-Courmont escreve=
u:
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/Kconfig  |   11 +++++++++++
>  net/phonet/Makefile |    3 +++
>  2 files changed, 14 insertions(+), 0 deletions(-)
>  create mode 100644 net/phonet/Kconfig
>  create mode 100644 net/phonet/Makefile
>=20
> diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
> new file mode 100644
> index 0000000..02f8921
> --- /dev/null
> +++ b/net/phonet/Kconfig
> @@ -0,0 +1,11 @@
> +#
> +# Phonet protocol
> +#
> +
> +config PHONET
> +	tristate "Phonet protocols family"
> +	help
> +	  Phonet is a communication protocol used by Nokia modems.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called phonet. If unsure, say N.

I think you could expand this a bit, no? Telling in which platforms thi=
s
would be used, i.e. nokia devices such as the N8x0 and not on a desktop
with a Nokia modem attached, etc.

Recently there were complaints about Kconfig help entries being too
terse, lets not add more of these.

- Arnaldo
