From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 16:23:10 +0100
Message-ID: <1328109790.2595.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	  <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	  <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	  <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328109279.13003.YahooMailNeo@web29014.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yao zhao <yao.development@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44949 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab2BAPXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 10:23:13 -0500
Received: by wgbdt10 with SMTP id dt10so1421050wgb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 07:23:12 -0800 (PST)
In-Reply-To: <1328109279.13003.YahooMailNeo@web29014.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 15:14 +0000, Leonardo Uzcudun a=
 =C3=A9crit :
> Yes, all those points are clear. My question is: can i do anything in
> the linux side (i can't change the switch config) to make the traffic
> on vlan 1 to function?
>=20
> Example: how do those linux-wifi-access points that support vlans are
> able to have VLAN 1 and other vlans?

eth0 will receive your "untagged" traffic, exactly if you had no vlan
config on your machine.

eth0 will send your "untagged" traffic, exactly if you had no vlan
config on your machine.

If "eth0" name doesnt please you, you can rename it to eth0.1 or
eth0.untag


ip link set dev eth0 name eth0.untag
