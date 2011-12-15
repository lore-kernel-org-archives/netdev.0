From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Thu, 15 Dec 2011 19:54:37 +0100
Message-ID: <1323975277.2769.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	 <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA3D58.5010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41646 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1LOSyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 13:54:41 -0500
Received: by werm1 with SMTP id m1so162939wer.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 10:54:40 -0800 (PST)
In-Reply-To: <4EEA3D58.5010101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 10:32 -0800, Rick Jones a =C3=A9c=
rit :
> > More exactly, we call dev_queue_xmit_nit() from dev_hard_start_xmit=
()
> > _before_ giving skb to device driver.
> >
> > If device driver returns NETDEV_TX_BUSY, and a qdisc was setup on t=
he
> > device, packet is requeued.
> >
> > Later, when queue is allowed to send again packets, packet is
> > retransmitted (and traced a second time in dev_queue_xmit_nit())
>=20
> Is this then an unintended consequence bug, or a known feature?
>=20

Its a well known feature, some people attempted to remove it ;)

http://answers.softpicks.net/answers/topic/-PATCH-tcpdump-may-trace-som=
e-outbound-packets-twice--2204640-1.htm
