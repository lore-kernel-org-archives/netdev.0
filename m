From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 22:32:25 +0200
Message-ID: <1302121945.2701.31.camel@edumazet-laptop>
References: <20110406195719.GE14697@ghostprotocols.net>
	 <20110406.130239.232756965.davem@davemloft.net>
	 <1302121136.2701.16.camel@edumazet-laptop>
	 <20110406.132906.200378990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@ghostprotocols.net, jesse.brandeburg@gmail.com,
	fedora-kernel-list@redhat.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38138 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755805Ab1DFUca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:32:30 -0400
Received: by wwa36 with SMTP id 36so2235968wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 13:32:29 -0700 (PDT)
In-Reply-To: <20110406.132906.200378990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 13:29 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Apr 2011 22:18:56 +0200
>=20
> > I remember last time I work on a fedora kernel, it had conntrack en=
abled
> >=20
> > And yes, conntrack can really slowdown a router, because of default
> > parameters.
>=20
> Yes, if conntrack is enabled performance will indeed tank.

I just check on latest fedora14 (yum updated) :

- conntrack is statically included in kernel, you cannot remove it.


Hmm...


