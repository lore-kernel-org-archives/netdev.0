From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 8/8] ipv6: add documentation for stable_secret,
 idgen_delay and idgen_retries knobs
Date: Mon, 23 Mar 2015 10:13:55 -0700
Message-ID: <1427130835.25985.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1427129103.git.hannes@stressinduktion.org>
	 <6da46ae2f76bf9aca41bd09ea7f284b75955637c.1427129103.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ek@google.com, fgont@si6networks.com,
	lorenzo@google.com, hideaki.yoshifuji@miraclelinux.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36610 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbbCWRN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:13:58 -0400
Received: by iedm5 with SMTP id m5so41055859ied.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 10:13:58 -0700 (PDT)
In-Reply-To: <6da46ae2f76bf9aca41bd09ea7f284b75955637c.1427129103.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 18:02 +0100, Hannes Frederic Sowa wrote:
> Cc: Erik Kline <ek@google.com>
> Cc: Fernando Gont <fgont@si6networks.com>
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Cc: YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.y=
oshifuji@miraclelinux.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  Documentation/networking/ip-sysctl.txt | 25 ++++++++++++++++++++++++=
+
>  1 file changed, 25 insertions(+)
>=20
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/n=
etworking/ip-sysctl.txt
> index 6c07c2b..6825247 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1220,6 +1220,17 @@ anycast_src_echo_reply - BOOLEAN
>  	FALSE: disabled
>  	Default: FALSE
> =20
> +idgen_delay - INTEGER
> +	Controls the delay in seconds after which time to retry
> +	privacy stable address generation if a DAD conflict is
> +	detected.
> +	Default: 1 (as specified in RFC7212)
> +
> +idgen_retries - INTEGER
> +	Controls the number of retries to generate a stable privacy
> +	address if a DAD conflict is detected.
> +	Default: 3 (as specified in RFC7212)
> +

I thought you were implementing RFC7217 ?
