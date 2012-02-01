From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 01 Feb 2012 10:25:44 +0100
Message-ID: <1328088344.2595.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
			 <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
	 <1328072958.2617.34.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5B932C9@EUSAACMS0702.eamcs.ericsson.se>
	 <1328082833.22641.9.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5B932CF@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61039 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab2BAJZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 04:25:49 -0500
Received: by wgbdt10 with SMTP id dt10so1048850wgb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 01:25:47 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5B932CF@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 03:11 -0500, Shawn Lu a =C3=A9c=
rit :
> Why? Do you mean packet is droped by netfilter before getting to tcp =
and No RST is generated.=20

Hmm, net/ipv4/netfilter/ipt_REJECT.c / net/ipv6/netfilter/ip6t_REJECT.c
are able to sent RST packets. I presume this is not md5 aware.
