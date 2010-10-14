From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 06:01:21 +0200
Message-ID: <1287028881.2649.103.camel@edumazet-laptop>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
	 <4CB1A22B.9090701@gmail.com>
	 <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	 <20101012101022.GA8578@ff.dom.local>
	 <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	 <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com>
	 <20101013062649.GA6915@ff.dom.local>
	 <20101013233653.1e363692.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37703 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778Ab0JNEBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 00:01:42 -0400
Received: by wwj40 with SMTP id 40so7388301wwj.1
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 21:01:41 -0700 (PDT)
In-Reply-To: <20101013233653.1e363692.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 23:36 -0400, Bill Fink a =C3=A9crit =
:

> I was just trying to do an 8 Gbps rate limit on a 10-GigE path,
> and couldn't get it to work with either htb or tbf.  Are you
> saying this currently isn't possible?  Or are you saying to use
> this hfsc mechanism, which there doesn't seem to be a man page
> for?

man pages ? Oh well...

8Gbps rate limit sounds very optimistic with a central lock and one
queue...

Maybe its possible to split this into 8 x 1Gbps, using 8 queues...
or 16 x 500 Mbps



