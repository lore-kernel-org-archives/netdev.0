From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 1/2] lib: fix warning in namespace.h
Date: Thu, 15 Jan 2015 13:33:47 +0200
Message-ID: <20150115113347.GA17587@angus-think.wlc.globallogic.com>
References: <1421318185-10858-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Vadim Kochan <vadim4j@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:46718 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbAOLoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 06:44:21 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so13108782lam.2
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 03:44:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1421318185-10858-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 11:36:24AM +0100, Nicolas Dichtel wrote:
> Warning was:
> In file included from bridge.c:16:0:
> ../include/namespace.h:33:12: warning: =E2=80=98setns=E2=80=99 define=
d but not used [-Wunused-function]
>=20
> CC: Vadim Kochan <vadim4j@gmail.com>
> Fixes: eb67e4498aec ("lib: Add netns_switch func for change network n=
amespace")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/namespace.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/include/namespace.h b/include/namespace.h
> index b8c5cad6aaa2..28a4223b3eb2 100644
> --- a/include/namespace.h
> +++ b/include/namespace.h
> @@ -30,7 +30,7 @@
>  #endif
> =20
>  #ifndef HAVE_SETNS
> -static int setns(int fd, int nstype)
> +static inline int setns(int fd, int nstype)
>  {
>  #ifdef __NR_setns
>  	return syscall(__NR_setns, fd, nstype);
> --=20
> 2.1.0
>=20
Thank You Nicolas!
I have to do more testing before send a patches.

Thanks,
