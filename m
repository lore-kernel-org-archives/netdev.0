From: =?UTF-8?B?U3TDqXBoYW5lIEdsb25kdQ==?= <glondu@debian.org>
Subject: Re: Bug#709616: floods the network with pause packets
Date: Thu, 30 May 2013 15:07:44 +0200
Message-ID: <51A74F20.4000500@debian.org>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>    <20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org>   <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>   <51A1CFB7.1080808@debian.org>  <1369584645.3469.343.camel@deadeye.wl.decadent.org.uk>  <51A719FD.9020506@debian.org> <1369918724.3469.445.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 709616@bugs.debian.org, e1000-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:4690 "EHLO
	mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754646Ab3E3NHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:07:45 -0400
In-Reply-To: <1369918724.3469.445.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2013 14:58, Ben Hutchings a =C3=A9crit :
>>> Could you check whether the switch is also sending pause frames bac=
k to
>>> the port that's generating them?
>>
>> How exactly do I do that? Is disconnecting the faulty computer and
>> connecting my laptop in its place right?
>=20
> ethtool -S eth0 | grep flow_control

     rx_flow_control_xon: 318
     rx_flow_control_xoff: 318
     tx_flow_control_xon: 0
     tx_flow_control_xoff: 0

--=20
St=C3=A9phane
