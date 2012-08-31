From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH 0/3] tcp: TCP Fast Open, Server Side
Date: Fri, 31 Aug 2012 15:27:41 -0700
Message-ID: <CAPshTCgxo==q1Om1vrfi9auZ4eHv=Vtte6ijk3+tzaBk9_vH6g@mail.gmail.com>
References: <1346369948-1722-1-git-send-email-hkchu@google.com>
	<20120831.165300.1630700722681560552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34244 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753714Ab2HaW1n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:27:43 -0400
Received: by lagy9 with SMTP id y9so2594438lag.19
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 15:27:42 -0700 (PDT)
In-Reply-To: <20120831.165300.1630700722681560552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 31, 2012 at 1:53 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Thu, 30 Aug 2012 16:39:05 -0700
>
>> This patch series provides the server (passive open) side code
>> for TCP Fast Open. Together with the earlier client side patches
>> it completes the TCP Fast Open implementation.
>
> Build warnings:
>
> net/ipv4/tcp_ipv4.c: In function =91tcp_v4_conn_request=92:
> net/ipv4/tcp_ipv4.c:1480:25: warning: unused variable =91fastopenq=92=
 [-Wunused-variable]
>
> Please address this and Eric Dumazet's feedback, thanks.

Thanks for catching this (a manual mistake while trying to keep my thre=
e TFO
server patches for three different kernel versions all in sync). I
also discovered
and fixed another small merge error - "do_fastopen" in tcp_v4_conn_requ=
est() no
longer needs to be init'ed to 0.

Will send in v2 in a minute.

Jerry
