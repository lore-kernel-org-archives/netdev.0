From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix bug when gap in rcv sequence is filled
Date: Thu, 5 Apr 2012 15:21:50 -0400
Message-ID: <CAAsGZS4MZmMnLGSg=GnTMV6iHv1NuaroxEfdTEPxXOTQmihWmw@mail.gmail.com>
References: <1333651563-3279-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com,
	ilpo.jarvinen@helsink.fi
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34047 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609Ab2DETVv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 15:21:51 -0400
Received: by pbcun15 with SMTP id un15so1868256pbc.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 12:21:51 -0700 (PDT)
In-Reply-To: <1333651563-3279-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 5, 2012 at 2:46 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> +static int tcp_ofo_queue(struct sock *sk)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tcp_sock *tp =3D tcp_sk(sk);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 dsack_high =3D tp->rcv_nxt;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb;
> + =C2=A0 =C2=A0 =C2=A0 bool requeued =3D false; /*true if an skb is r=
equeued to receive_queue*/

why introduce a bool then ? Change it to int(init to 0) and then
'return requeued' ?

Chetan
