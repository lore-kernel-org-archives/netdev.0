From: Peter Teoh <htmldeveloper@gmail.com>
Subject: Re: CPU instruction to calculate tcp checksum and udp integrity?
Date: Thu, 26 May 2011 10:57:28 +0800
Message-ID: <BANLkTimtRFFNWthCN1ziLtuNvFYAi0WHGg@mail.gmail.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D8894E6@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernelnewbies@kernelnewbies.org" <kernelnewbies@kernelnewbies.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60807 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1EZC53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 22:57:29 -0400
Received: by vws1 with SMTP id 1so229678vws.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 19:57:28 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D8894E6@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In net/ipv4/tcp_ipv4.c:

/* This routine computes an IPv4 TCP checksum. */
void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb)
{
        struct inet_sock *inet = inet_sk(sk);

        __tcp_v4_send_check(skb, inet->inet_saddr, inet->inet_daddr);
}
EXPORT_SYMBOL(tcp_v4_send_check);


On Mon, May 23, 2011 at 11:26 PM, Jon Zhou <Jon.Zhou@jdsu.com> wrote:
> hi
> now I am using sw to calculate the tcp checksum, is there CPU(nehalem)
> instruction or NIC /kernel API to do such thing?
>
> thanks a lot
> jon
>
>
> _______________________________________________
> Kernelnewbies mailing list
> Kernelnewbies@kernelnewbies.org
> http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies
>
>



-- 
Regards,
Peter Teoh
