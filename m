From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 19:30:05 +0800
Message-ID: <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com>
	 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
	 <20091103100538.GC6718@ff.dom.local>
	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
	 <20091103230035.GA2352@ami.dom.local>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
	 <20091104104245.GB6224@ff.dom.local> <4AF15E73.30806@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Martin Devera <martin.devera@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:33461 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbZKDLaA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 06:30:00 -0500
Received: by pzk26 with SMTP id 26so4624158pzk.4
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 03:30:05 -0800 (PST)
In-Reply-To: <4AF15E73.30806@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 6:58 PM, Martin Devera <martin.devera@cdi.cz> wr=
ote:
>
> Hello,
>
> yes you are right. If I remember correctly, I tried to charge "rate"
> tokens up to root in early versions (which makes some sense) but prob=
lem
> is with many interior classes stuck at extreme mbuffer value, losing
> responsivity.

It is strange. Would you like describe it more clearly?

> Also it didn't played well with prio settings (class
> stalls).

Was it the cause?

> Bacause we don't charge "rate" now, some amount of burst can accumula=
te
> in each interior class and decrease fairness at the same prio level a=
 bit.
> However from measurments I did, these bursts of unfairness are
> hidded by regular "bursting" of rate and ceil token buckets.
>

One case for unfairness.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
