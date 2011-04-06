From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fedora 14 kernel performance with ip forwarding workload
Date: Wed, 06 Apr 2011 23:11:09 +0200
Message-ID: <1302124269.2701.36.camel@edumazet-laptop>
References: <20110406195719.GE14697@ghostprotocols.net>
	 <20110406.130239.232756965.davem@davemloft.net>
	 <1302121136.2701.16.camel@edumazet-laptop>
	 <20110406.132906.200378990.davem@davemloft.net>
	 <1302121945.2701.31.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1104061400320.6556@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"acme@ghostprotocols.net" <acme@ghostprotocols.net>,
	"jesse.brandeburg@gmail.com" <jesse.brandeburg@gmail.com>,
	"fedora-kernel-list@redhat.com" <fedora-kernel-list@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36668 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab1DFVLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:11:14 -0400
Received: by wwa36 with SMTP id 36so2269858wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 14:11:13 -0700 (PDT)
In-Reply-To: <alpine.WNT.2.00.1104061400320.6556@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 14:08 -0700, Brandeburg, Jesse a =C3=A9=
crit :
> Thanks for the replies,=20
> Yes indeed, I bet that conntrack was the item that caused the grief I=
 saw. =20
> In fact turning off CONFIG_NETFILTER disables conntrack and solved my=
=20
> problem. :-)
>=20
> Now the question is how to get the netfiltery/conntracky goodness wit=
hout=20
> impacting those who want to go fast, maybe without a helmet.

Thats pretty simple, just load netfilter modules if necessary.

If not loaded, cost is pretty small, being predicted branches.



