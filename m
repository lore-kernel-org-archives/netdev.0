From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/net/wireless/ath/wil6210: Makefile, only -Werror
 when no -W* in EXTRA_CFLAGS
Date: Wed, 27 Feb 2013 18:01:16 +0800
Message-ID: <512DD96C.5060001@asianux.com>
References: <512DADCA.9040609@asianux.com> <1385870.TegBXpTM9i@lx-vladimir> <512DCA59.4040800@asianux.com> <1921426.IqHmmMU5eP@lx-vladimir>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	"netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:35721 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab3B0KBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 05:01:38 -0500
In-Reply-To: <1921426.IqHmmMU5eP@lx-vladimir>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 17:46, Vladimir Kondratie=
v =E5=86=99=E9=81=93:
> Perhaps, it would be good idea to fight the original problem.
>=20

  if my another 'beautify code' patches are applied into next-* tree.
    (that means most of members think it is a good idea).
    I will process the original problems (when processing, also cc to y=
ou).

  :-)

> I mean, fix warnings where possible. Example: there are lots of
> "unused parameter" ones. Where it is false warning, add __maybe_unuse=
d
> attribute. Like this:
>=20
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index c566927..83e43b7 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -163,8 +163,9 @@ extern int _cond_resched(void);
>  # define might_sleep() \
>         do { __might_sleep(__FILE__, __LINE__, 0); might_resched(); }=
 while (0)
>  #else
> -  static inline void __might_sleep(const char *file, int line,
> -                                  int preempt_offset) { }
> +  static inline void __might_sleep(const char *file __maybe_unused,
> +                                  int line __maybe_unused,
> +                                  int preempt_offset __maybe_unused)=
 { }
>  # define might_sleep() do { might_resched(); } while (0)
>  #endif
> =20

  thank you for your demo, it is valuable to me.

  :-)


--=20
Chen Gang

Asianux Corporation
