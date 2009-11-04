From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 20:08:35 +0800
Message-ID: <412e6f7f0911040408w5adcdde8yc1add4a561e90e40@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com>
	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
	 <20091103230035.GA2352@ami.dom.local>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
	 <20091104104245.GB6224@ff.dom.local> <4AF15E73.30806@cdi.cz>
	 <412e6f7f0911040330uc5ebbcekfef57854fce501f@mail.gmail.com>
	 <4AF16C49.409@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Martin Devera <martin.devera@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:45147 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbZKDMIa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 07:08:30 -0500
Received: by pwj9 with SMTP id 9so3134185pwj.21
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 04:08:35 -0800 (PST)
In-Reply-To: <4AF16C49.409@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 7:58 PM, Martin Devera <martin.devera@cdi.cz> wr=
ote:
>
> Ahh I'm starting to understand. You are concerned mainly with
>
> cl->tokens +=3D diff; =C2=A0 =C2=A0 /* we moved t_c; update tokens */
>
> am I right ?
>

If we don't need to charge the tokens, updating it is necessary. I am
arguing the tokens isn't updated with the ctokens when the
corresponding class is in HTB_MAY_BORROW mode.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
