From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 04 Feb 2012 19:29:54 +0100
Message-ID: <1328380194.2731.33.camel@edumazet-laptop>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
	 <1328342816.2577.8.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FCF6@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61226 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302Ab2BDSaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 13:30:20 -0500
Received: by werb13 with SMTP id b13so3426267wer.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 10:30:19 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5C9FCF6@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 13:15 -0500, Shawn Lu a =C3=A9cri=
t :

> It won't work.  For RST, socket is gone.=20

If this was true, we would not have :

tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)

but :

tcp_v4_send_reset(struct sk_buff *skb)


Think about it.

You write a lot, but you dont really understand what I wrote in my
previous mails, do you ?
