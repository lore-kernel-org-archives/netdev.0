From: Dan Finn <Dan.Finn@plansource.com>
Subject: RX overrun errors building on several of our hosts
Date: Mon, 3 Aug 2015 22:38:01 +0000
Message-ID: <DM2PR07MB670C5AE859AC24DB9AAF869F1770@DM2PR07MB670.namprd07.prod.outlook.com>
References: <DM2PR07MB670383331D9D645D83D9ADAF1770@DM2PR07MB670.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport.plansource.com ([66.35.92.40]:45918 "EHLO
	ironport.plansource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435AbbHCWiF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 18:38:05 -0400
In-Reply-To: <DM2PR07MB670383331D9D645D83D9ADAF1770@DM2PR07MB670.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After implementing a new monitoring tool I've noticed that several of o=
ur physical servers have increasing RX errors, all seem to be classifie=
d as overruns.


The interfaces are=A0Broadcom Corporation BCM57840 NetXtreme II 10 Giga=
bit Ethernet (rev 11) and we are using the bnx2x driver. =A0The are con=
figured in a bond0 using mode 0 or balance-rr. =A0We are not seeing any=
 errors on the switch and my guess is that this  is either a config iss=
ue or driver problem since it's happening on multiple servers. =A0All t=
he interfaces appear to be connected at 10 gig full duplex. =A0The serv=
ers are Dell M620s. =A0 I've gathered as much related info as I could t=
hink of that would be helpful,  it can be found in this paste:

http://pastebin.centos.org/31716/

I'm not entirely sure where to look next, any help would be much apprec=
iated.

Thanks,
Dan
     