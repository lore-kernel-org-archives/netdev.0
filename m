From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 18:27:37 +0200
Message-ID: <1306254457.3026.69.camel@edumazet-laptop>
References: <20110524074156.58eb30f8@nehalam>
	 <1306251543.3026.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35757 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab1EXQ1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 12:27:41 -0400
Received: by wwa36 with SMTP id 36so7520670wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 09:27:40 -0700 (PDT)
In-Reply-To: <1306251543.3026.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 17:39 +0200, Eric Dumazet a =C3=A9crit :

> I would say its more likely a problem with dst metrics changes
>=20
> In this crash, we dereference a NULL dst->_metrics 'pointer' in
> dst_metric_raw(dst, RTAX_MTU);

It seems bridge code uses one fake_rtable

You probably want to properly init its _metric field.

I can do the patch in one hour eventually, if nobody beats me.



