From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:01:32 +0100
Message-ID: <4B0711BC.7010900@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <4B0701E2.1070806@gmail.com>	 <4B070BAC.1090406@gmail.com> <1258753414.28239.66.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37471 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbZKTWBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:01:36 -0500
In-Reply-To: <1258753414.28239.66.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches a =C3=A9crit :
>=20
> Prefixing member names generally doesn't end well.
> Prefixing selected member names? ick.

Yes, but Rome was not built in one day my friend :)

This patch makes Jarek point more obvious : Dont reuse iif or risk
new bugs.
