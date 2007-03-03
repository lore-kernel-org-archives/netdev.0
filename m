From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Sat, 3 Mar 2007 13:04:17 +0100
Message-ID: <200703031304.17375.stefan@loplof.de>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net> <20070302.132638.38710461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:44958 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211AbXCCMGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 07:06:07 -0500
In-Reply-To: <20070302.132638.38710461.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 2. M=E4rz 2007 22:26 schrieb David Miller:

> The DHCP client should only care about a particular interface's
> traffic, the one it wants to listen on.

Also, a DHCP client should close the socket between address acquisition=
 and=20
renewal. The only interesting events in that period are operstate chang=
es.

Stefan
