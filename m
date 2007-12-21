From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 07:18:13 -0500
Message-ID: <476BAF05.6040809@garzik.org>
References: <476B574E.80601@cosmosbay.com>	<20071221.155030.131184865.yoshfuji@linux-ipv6.org>	<476BA2F8.1090102@garzik.org> <20071221.035717.243469952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45292 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbXLUMSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 07:18:16 -0500
In-Reply-To: <20071221.035717.243469952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 21 Dec 2007 06:26:48 -0500
>=20
>> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>>> In article <476B574E.80601@cosmosbay.com> (at Fri, 21 Dec 2007 07:0=
3:58 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>>>
>>>> Because tot_len is signed in tcp_v6_send_ack(), tot_len/4 forces c=
ompiler
>>>> to emit an integer divide, while we can help it to use a right shi=
ft,
>>>> less expensive.
>>> Are you really sure?
>>> At least, gcc-4.1.2-20061115 (debian) does not make any difference.
>> Quite true -- thus it is a matter of taste to the programmer.
>=20
> Not true, the code output does change, check your optimize-for-size
> kernel config setting.
>=20
> This was discussed and explained later in this thread, and I also
> explained it to you on IRC Jeff ;-)

[looks]

=46or signed integers, this is true.

=46or unsigned integers, the code output is the same, regardless of=20
optimization setting.

	Jeff


