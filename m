From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 16:41:12 +0100
Message-ID: <1299080472.2920.7.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64041 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab1CBPl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 10:41:26 -0500
Received: by fxm17 with SMTP id 17so101321fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 07:41:25 -0800 (PST)
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 17:17 -0800, Stephen Hemminger a =C3=
=A9crit :


> --- a/include/linux/pkt_sched.h	2011-02-28 13:28:57.763177314 -0800
> +++ b/include/linux/pkt_sched.h	2011-02-28 13:29:10.466792117 -0800
> @@ -588,4 +588,18 @@ struct tc_sfb_xstats {
> =20
>  #define SFB_MAX_PROB 0xFFFF
> =20
> +/* QFQ */
> +enum {

+	TCA_QFQ_UNSPEC,

> +	TCA_QFQ_WEIGHT,
> +	TCA_QFQ_LMAX,
> +	__TCA_QFQ_MAX
> +};
> +
> +#define TCA_QFQ_MAX	(__TCA_QFQ_MAX - 1)
> +

With TCA_QFQ_UNSPEC bit (and mirror the change in iproute2), it seems t=
o
work better.

Oh wait, I had a crash in qfq_reset_qdisc() when re-running my setup
script.



