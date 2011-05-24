From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use synchronize_rcu_expedited()
Date: Tue, 24 May 2011 21:44:45 +0200
Message-ID: <1306266285.3305.3.camel@edumazet-laptop>
References: <1306228052.3026.16.camel@edumazet-laptop>
	 <20110524154445.GC2266@linux.vnet.ibm.com>
	 <1306252364.3026.63.camel@edumazet-laptop>
	 <20110524192451.GH2266@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64270 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab1EXTot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 15:44:49 -0400
Received: by wwk4 with SMTP id 4so2794489wwk.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 12:44:48 -0700 (PDT)
In-Reply-To: <20110524192451.GH2266@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 12:24 -0700, Paul E. McKenney a =C3=A9crit =
:

> Might make sense, though most of the gains would need to come from
> kicking the grace-period machinery hard in order to make it go faster=
=2E
>=20
> Interesting -- I will give this some thought.
>=20

I am working on a final step, using a workqueue so that the
rcu_barrier() is not done under RTNL, so it wont be anymore a blocking
point to dismantle hundred of devices per second...

Thanks


