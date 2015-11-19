From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] Add missing <sys/types.h> include
Date: Thu, 19 Nov 2015 14:31:48 -0800
Message-ID: <20151119143148.70764efa@xeon-e3>
References: <1447967140-29909-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1447967140-29909-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33611 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbbKSWbf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:31:35 -0500
Received: by pabfh17 with SMTP id fh17so97396008pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:31:35 -0800 (PST)
In-Reply-To: <1447967140-29909-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Nov 2015 22:05:40 +0100
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> The u_intXX_t types are defined in <sys/types.h>, so it should be
> included before using those types. Otherwise, with certain C
> libraries, the build fails with:
>=20
> In file included from ../include/iptables.h:4:0,
>                  from m_ipt.c:18:
> ../include/iptables_common.h:47:16: error: unknown type name =E2=80=98=
u_int32_t=E2=80=99
>  #define __le32 u_int32_t
>=20
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  include/iptables_common.h | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/include/iptables_common.h b/include/iptables_common.h
> index 9099667..2c27a4b 100644
> --- a/include/iptables_common.h
> +++ b/include/iptables_common.h
> @@ -43,6 +43,8 @@ extern char *lib_dir;
>    extern void init_extensions(void);
>  #endif
> =20
> +#include <sys/types.h>
> +
>  #define __be32	u_int32_t
>  #define __le32	u_int32_t
>  #define __be16	u_int16_t

I would prefer you send this one through the iptables team
since that header file came from there.
