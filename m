From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [Socketcan-users] [PATCH] CAN: make checking in can_rcv less restrictive
Date: Fri, 7 Aug 2009 14:54:27 +0300
Message-ID: <200908071454.28096.remi.denis-courmont@nokia.com>
References: <1249572295-7801-1-git-send-email-l.fu@pengutronix.de> <200908070952.56922.remi.denis-courmont@nokia.com> <4A7C117E.5010005@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"socketcan-users@lists.berlios.de" <socketcan-users@lists.berlios.de>
To: ext Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:20695 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbZHGLy2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 07:54:28 -0400
In-Reply-To: <4A7C117E.5010005@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 August 2009 14:35:26 ext Oliver Hartkopp wrote:
> So you would need to have an originating interface with ARPHRD_CAN ..=
=2E
>
> Do you think, it's still possible with the TUN driver?

Hmm, actually no... TUN can create packets with any type (ETH_P_*), but=
=20
devices always have ARPHRD_NONE type.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

