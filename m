From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 1/2] [SCTP]: Kill unused static inline sctp_sysctl_jiffies_ms
Date: Fri, 29 Feb 2008 12:09:45 -0500
Message-ID: <47C83C59.9000304@hp.com>
References: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:47039 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbYB2RJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 12:09:51 -0500
In-Reply-To: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> After the patch:
> $ git-grep sctp_sysctl_jiffies_ms | wc -l
> 0
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>

Good catch.  Looks like dead declaration.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Thanks
-vlad

> ---
>  include/net/sctp/sctp.h |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index 57df27f..a653eb3 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -368,11 +368,6 @@ void sctp_sysctl_unregister(void);
>  #else
>  static inline void sctp_sysctl_register(void) { return; }
>  static inline void sctp_sysctl_unregister(void) { return; }
> -static inline int sctp_sysctl_jiffies_ms(ctl_table *table, int __use=
r *name, int nlen,
> -		void __user *oldval, size_t __user *oldlenp,
> -		void __user *newval, size_t newlen) {
> -	return -ENOSYS;
> -}
>  #endif
> =20
>  /* Size of Supported Address Parameter for 'x' address types. */

