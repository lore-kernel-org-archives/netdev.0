From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 25 Mar 2010 14:19:40 +0100
Message-ID: <1269523180.3626.25.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
	 <1268686865.2824.4.camel@edumazet-laptop>
	 <1268699602.2824.14.camel@edumazet-laptop>
	 <20100316145914.GB3332@swordfish.minsk.epam.com>
	 <1268751933.3094.45.camel@edumazet-laptop>
	 <20100316151023.GC3332@swordfish.minsk.epam.com>
	 <1268752826.3094.48.camel@edumazet-laptop>
	 <20100316182619.GA3451@swordfish>
	 <1268765284.2932.17.camel@edumazet-laptop>
	 <20100325113038.GA3471@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:58502 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab0CYNTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 09:19:45 -0400
Received: by bwz1 with SMTP id 1so832304bwz.21
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 06:19:43 -0700 (PDT)
In-Reply-To: <20100325113038.GA3471@swordfish.minsk.epam.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 13:30 +0200, Sergey Senozhatsky a =C3=A9cr=
it :
> Hello,
>=20
> On (03/16/10 19:48), Eric Dumazet wrote:
> [..]
> > OK thanks for the report, this rtl8169_reset_task() seems pretty bu=
ggy,
> > or multiple invocation...
> >=20
> > Did you tried removing the rtl8169_schedule_work() call from
> > rtl8169_rx_interrupt() ?
> >=20
> > Maybe the reset is not necessary at all in case of fifo overflow..
> >=20
> > Cumulative patch :
> >=20
> [..]
>=20
> Eric, I think you can put Tested-by: Sergey Senozhatsky <sergey.senoz=
hatsky@gmail.com>
> on the cumulative patch as I don't see any errors with pktgen over LA=
N testing.
>=20

Hi

Thanks for the report. Problem is I am not confident enough on this
driver.
I believe Fran=C3=A7ois Romieu is the one that can possibly push a patc=
h ?

Thanks


