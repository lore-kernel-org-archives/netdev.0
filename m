From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 7/8] net: introduce rx_handler results and
 logic around that
Date: Sun, 6 Mar 2011 00:45:47 +0800
Message-ID: <AANLkTi=AYQsO4F3s3Mqxj6QaT=xMKp_hBE12qC3e0uF-@mail.gmail.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com> <1299313794-5218-8-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45145 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab1CEQqI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 11:46:08 -0500
Received: by fxm17 with SMTP id 17so3023008fxm.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 08:46:07 -0800 (PST)
In-Reply-To: <1299313794-5218-8-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 5, 2011 at 4:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>
> -typedef struct sk_buff *rx_handler_func_t(struct sk_buff *skb);
> +enum rx_handler_result {
> + =A0 =A0 =A0 RX_HANDLER_CONSUMED,
> + =A0 =A0 =A0 RX_HANDLER_ANOTHER,
> + =A0 =A0 =A0 RX_HANDLER_EXACT,
> + =A0 =A0 =A0 RX_HANDLER_PASS,
> +};

Why not extend the macros NET_RX_SUCCESS and NET_RX_DROP?  Then the
callers of __netif_receive_skb() may get the right congestion info
from its return value.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
