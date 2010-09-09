From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems obtaining software TX timestamps
Date: Thu, 09 Sep 2010 20:58:50 +0200
Message-ID: <1284058730.2298.74.camel@edumazet-laptop>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
	 <1283958771.2748.85.camel@edumazet-laptop>
	 <4C87FE60.7090209@edu.uni-klu.ac.at>
	 <20100909063541.GA3305@riccoc20.at.omicron.at>
	 <4C889A1E.6050405@edu.uni-klu.ac.at>
	 <20100909135716.GA8706@riccoc20.at.omicron.at>
	 <1284040958.2589.178.camel@edumazet-laptop>
	 <20100909173228.GA2657@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Kofler <ikofler@edu.uni-klu.ac.at>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33088 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab0IIS7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 14:59:01 -0400
Received: by wyf22 with SMTP id 22so1750671wyf.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 11:58:57 -0700 (PDT)
In-Reply-To: <20100909173228.GA2657@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 septembre 2010 =C3=A0 19:32 +0200, Richard Cochran a =C3=A9=
crit :
> On Thu, Sep 09, 2010 at 04:02:38PM +0200, Eric Dumazet wrote:
> > Should drivers call it at start_xmit() time, or at tx completion ti=
me ?
>=20

> IMHO, it should be done as immediately after the buffer has been
> handed off to the hardware. Not all MACs have a completion method, so
> that would at least make the "rule" consistent.
>=20

Well, all drivers must release skb *somewhere*, either in their
ndo_start_xmit() or TX completion ;)

> In general, the goals of high volume and timestamp accuracy are in
> conflict (unless you have HW timestamping). If users are relying on S=
W
> timestamping, then they should be aware of the fact that high network
> traffic will spoil their fun.
>=20

- Full duplex mode wanted
- And small TX rings



