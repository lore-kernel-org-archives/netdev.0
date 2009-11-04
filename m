From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 20:01:23 +0800
Message-ID: <412e6f7f0911040401g5a8d58b0yc8c1637d419094f2@mail.gmail.com>
References: <20091103080022.GA6718@ff.dom.local>
	 <20091103100538.GC6718@ff.dom.local>
	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
	 <20091103230035.GA2352@ami.dom.local>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
	 <20091104104245.GB6224@ff.dom.local>
	 <412e6f7f0911040321o22c536fdid078f6d2225a90a0@mail.gmail.com>
	 <20091104114922.GA8176@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:61447 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639AbZKDMBS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 07:01:18 -0500
Received: by pxi9 with SMTP id 9so4572367pxi.4
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 04:01:23 -0800 (PST)
In-Reply-To: <20091104114922.GA8176@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 7:49 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
> On Wed, Nov 04, 2009 at 07:21:48PM +0800, Changli Gao wrote:
>>
>> I don't think so. Although a class's tokens may be negative, but its
>> ctokens may be positive. Charging its tokens is to prevent its cmode
>> from being changed to HTB_CAN_SEND from HTB_CANT_SEND directly.
>
> I think, you should really better show some tests proving your patch
> is needed and doesn't affect a case I described, instead of trying to
> discuss the meaninig of all HTB variables here.
>

I test it before sending it here, but it doesn't show any obvious
difference as Martin said, no worse and no better. I don't know how to
construct a test to show you the bad effect you worry about. Any
suggestion about the test?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
