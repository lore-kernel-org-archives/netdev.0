From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: reduce stack usage
Date: Tue, 12 Apr 2011 16:55:23 +0200
Message-ID: <1302620123.3233.58.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam> <4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302593469.3603.44.camel@edumazet-laptop>
	 <1302597580.3233.14.camel@edumazet-laptop>
	 <20110412235126.63841dfe.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Scot Doyle <lkml@scotdoyle.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53006 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163Ab1DLOz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 10:55:27 -0400
Received: by wwa36 with SMTP id 36so8002948wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 07:55:26 -0700 (PDT)
In-Reply-To: <20110412235126.63841dfe.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 23:51 +0900, Hiroaki SHIMODA a =C3=A9crit=
 :

> I couldn't understand that actually cleanup_once() was called
> from inet_getpeer() and then the stack overflow was hit,
> but this patch surely reduces stack usage.
>=20
> Reviewed-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
>=20

Well, I dont believe we actually hit a stack overflow in Scot Doyle
reported crashes, but it certainly is better to use a bit less stack
anyway ;)

Thanks for reviewing !


