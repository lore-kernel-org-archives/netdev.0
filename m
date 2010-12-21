From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 10:56:46 +0000
Message-ID: <20101221105646.GA8813@ff.dom.local>
References: <1292886976.2627.146.camel@edumazet-laptop> <20101221101506.GA8149@ff.dom.local> <20101221103026.GA8622@ff.dom.local> <1292928269.2720.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:53563 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab0LUK4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 05:56:53 -0500
Received: by fxm18 with SMTP id 18so4147568fxm.2
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 02:56:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292928269.2720.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 11:44:29AM +0100, Eric Dumazet wrote:
> Le mardi 21 d=E9cembre 2010 ?? 10:30 +0000, Jarek Poplawski a =E9crit=
 :
> > On Tue, Dec 21, 2010 at 10:15:06AM +0000, Jarek Poplawski wrote:
> > > The change of allotment limit looks OK [...]
> >=20
> > Hmm... but maybe s/ALLOT_ZERO/SFQ_ALLOT_ZERO/? ;-)
>=20
> Its a local symbol, its not like it being in an include file ;)

Sure, but why this one has to be different than others in this file?
(Plus, if you don't remember all this code it's a good hint.)

Jarek P.
