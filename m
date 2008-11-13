From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Thu, 13 Nov 2008 13:09:10 +0200
Message-ID: <200811131309.10693.remi.denis-courmont@nokia.com>
References: <1226572624.7164.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Balazs Scheidler" <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:43353 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbYKMLJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 06:09:29 -0500
In-Reply-To: <1226572624.7164.11.camel@bzorp.balabit>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 13 November 2008 12:37:04 ext Balazs Scheidler, you wrote:
> In case UDP traffic is redirected to a local UDP socket,
> the originally addressed destination address/port
> cannot be recovered with the in-kernel tproxy.
>
> This patch adds an IP_RECVORIGDSTADDR sockopt that enables
> a IP_ORIGDSTADDR ancillary message in recvmsg(). This
> ancillary message contains the original destination address/port
> of the packet being received.

Does this not duplicate the IP_PKTINFO functionality?

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
