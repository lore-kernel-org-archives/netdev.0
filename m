From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 14:05:36 +0100
Message-ID: <4BC31AA0.5070006@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>		 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>	  <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep12-int.chello.at ([62.179.121.32]:10118 "EHLO
	viefep12-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab0DLNFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 09:05:45 -0400
In-Reply-To: <1271076426.16881.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 12 avril 2010 =C3=A0 13:39 +0100, stephen mulcahy a =C3=A9cr=
it :
> I am not sure I understand. Are you saying that using 2.6.30-2-amd64
> kernel also makes your forcedeth adapter being not functional ?

Hi Eric,

If I run my tests with the 2.6.30-2-amd64 kernel the network doesn't=20
malfunction.

If I run my tests with the 2.6.32-3-amd64 kernel the network does=20
malfunction.

If I take the forcedeth.ko module from the 2.6.30-2-amd64 kernel and=20
drop that into /lib/modules/2.6.32-3-amd64/kernel/drivers/net/ and then=
=20
reboot to 2.6.32-3-amd64 and rerun my tests - the network does malfunct=
ion.

> Are both way non functional (RX and TX), or only one side ?

Whats the best way of testing this? (tcpdump listening on both hosts an=
d=20
then running pings between the systems?)

-stephen
