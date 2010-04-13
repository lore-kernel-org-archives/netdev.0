From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 12:49:26 +0200
Message-ID: <1271155766.16881.245.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
		 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
		 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
		 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>
		 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>
		 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>
	 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:40329 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab0DMKtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:49:39 -0400
Received: by bwz19 with SMTP id 19so19033bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 03:49:37 -0700 (PDT)
In-Reply-To: <4BC44167.4080807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 11:03 +0100, stephen mulcahy a =C3=A9crit=
 :
> Eric Dumazet wrote:
> > OK it seems forcedeth has problem with checksums ?
> >=20
> > Try to change "ethtool -k eth0" settings ?
> >=20
> > ethtool -K eth0 tso off tx off
>=20
> Yes, that makes an unresponsive system responsive again immediately, =
nice!
>=20
> Should the driver default to disabling this until we problem is corre=
cted?
>=20
> -stephen

Both flags need to be disabled, or only one is OK ?



