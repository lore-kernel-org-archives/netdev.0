From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 02 Nov 2010 05:53:42 +0100
Message-ID: <1288673622.2660.147.camel@edumazet-laptop>
References: <20101101122920.GB10052@verge.net.au>
	 <1288616372.2660.101.camel@edumazet-laptop>
	 <20101102020625.GA22724@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43277 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934094Ab0KBExu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 00:53:50 -0400
Received: by wyf28 with SMTP id 28so6257665wyf.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 21:53:49 -0700 (PDT)
In-Reply-To: <20101102020625.GA22724@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 novembre 2010 =C3=A0 11:06 +0900, Simon Horman a =C3=A9crit=
 :

> Thanks for the explanation.
> I'm not entirely sure how much of a problem this is in practice.

Maybe for virtual devices (tunnels, bonding, ...), it would make sense
to delay the orphaning up to the real device.

But if the socket send buffer is very large, it would defeat the flow
control any way...



