From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v3 1/6] can: extend sockaddr_can to include j1939 members
Date: Mon, 14 Mar 2011 15:15:00 +0100
Message-ID: <1300112100.3423.24.camel@edumazet-laptop>
References: <20110314132004.GA333@e-circ.dyndns.org>
	 <20110314132409.GB333@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39022 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745Ab1CNOPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:15:34 -0400
Received: by fxm17 with SMTP id 17so2931048fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 07:15:33 -0700 (PDT)
In-Reply-To: <20110314132409.GB333@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 14:24 +0100, Kurt Van Dijck a =C3=A9crit :

> +/*
> + * required_size
> + * macro to find the minimum size of a struct
> + * that includes a requested member
> + */
> +#define required_size(member, struct_type) \
> +	(offsetof(typeof(struct_type), member) + \
> +	 sizeof(((typeof(struct_type) *)(0))->member))
> +

Hmm, most similar macros reverse arguments.

(For example : offsetof())

What about

#define required_size(TYPE, MEMBER) ...



