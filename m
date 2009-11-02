From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/3] TCPCT part 1b: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Mon, 02 Nov 2009 05:45:22 -0500
Message-ID: <4AEEB842.1070705@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E529.706@gmail.com> <4AEDDDF3.3070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:48710 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbZKBKpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 05:45:21 -0500
Received: by yxe17 with SMTP id 17so4374728yxe.33
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 02:45:26 -0800 (PST)
In-Reply-To: <4AEDDDF3.3070102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> William Allen Simpson a =E9crit :
>> These functions will also be used in subsequent patches that impleme=
nt
>> additional features.
>>
>=20
> +#define TCP_EXTEND_TIMESTAMP	(1 << 4)	/* Initiate 64-bit timestamps =
*/
>=20
> What is this for ?
>=20
Reserving a bit in the sockopt for a future feature (described in the
aforementioned end2end-interest email messages).

Certainly, reserving bits seems to be common elsewhere in Linux code.  =
I'm
trying to coordinate this with the *BSD developers, too, so it helps to=
 keep
API documentation synchronized.  Is that a problem?
