From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/5] niu: fix 64 bit statistics on 32 bit
 platform
Date: Tue, 21 Jun 2011 00:02:32 +0200
Message-ID: <1308607352.2658.38.camel@edumazet-laptop>
References: <20110620203506.363818794@vyatta.com>
	 <20110620203602.739916889@vyatta.com>
	 <1308606356.2701.199.camel@bwh-desktop>
	 <20110620145201.42dd9bf8@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64643 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023Ab1FTWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 18:02:36 -0400
Received: by wyb38 with SMTP id 38so1980376wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 15:02:35 -0700 (PDT)
In-Reply-To: <20110620145201.42dd9bf8@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 14:52 -0700, Stephen Hemminger a =C3=A9cri=
t :
> > It looks like you also need to update release_tx_packet() where the=
se
> > stats are written.
>=20
> Probably need to split tx/rx update as well.

Its already done in your patch ;)



