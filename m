From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] rfs: Receive Flow Steering
Date: Tue, 6 Apr 2010 21:42:54 +0800
Message-ID: <u2n412e6f7f1004060642h56e60069k9fb896d273df56d1@mail.gmail.com>
References: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
	<1270559096.2081.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:37527 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab0DFNnO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 09:43:14 -0400
Received: by iwn35 with SMTP id 35so2185794iwn.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 06:43:14 -0700 (PDT)
In-Reply-To: <1270559096.2081.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 6, 2010 at 9:04 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> 1) The need to add "rps_flow_entries=3Dxxx" at boot time is problemat=
ic.
> =C2=A0 Maybe we can allow it being dynamic (and use vmalloc() instead=
 of
> alloc_large_system_hash())

Is flex_array better than vmalloc()?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
