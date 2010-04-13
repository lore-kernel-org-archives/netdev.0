From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 16:42:21 +0200
Message-ID: <1271169741.16881.437.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
				 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
				 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
				 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
				 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>
				 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>
			 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>
		 <1271155766.16881.245.camel@edumazet-laptop> <4BC44EC8.1010104@gmail.com>
	 <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
	 <4BC47F38.5040509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35965 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab0DMOma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 10:42:30 -0400
Received: by bwz19 with SMTP id 19so23321bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 07:42:29 -0700 (PDT)
In-Reply-To: <4BC47F38.5040509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 15:27 +0100, stephen mulcahy a =C3=A9crit=
 :
> Ok, I've tried both of the following with my reproducer
>=20
> 1. ethtool -K eth0 tso off
>=20
> RESULT: reproducer causes multiple hosts to be come unresponsive on=20
> first run.
>=20
> 2. ethtool -K eth0 tx off
>=20
> RESULT: reproducer runs three times without any hosts becoming unresp=
onsive.
>=20
> -stephen

Thanks Stephen !

Now some brave fouls to check the 6410 lines of this driver ? ;)

Question of the day : Why TSO is broken in forcedeth ?
Is it generically broken or is it broken for specific NICS ?


