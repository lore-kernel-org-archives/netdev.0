From: David Miller <davem@davemloft.net>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Thu, 02 Aug 2007 02:26:05 -0700 (PDT)
Message-ID: <20070802.022605.44936803.davem@davemloft.net>
References: <20070729160721.GA31276@1wt.eu>
	<46AEC286.2030302@netbauds.net>
	<Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darryl-mailinglists@netbauds.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbXHBJ0F convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 05:26:05 -0400
In-Reply-To: <Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 2 Aug 2007 12:23:23 +0300 (EEST)

> ...Seriously, somebody else than me is probably better in suggesting =
what=20
> could cause the discarding at the SERVER in this case. SNMP stuff Dav=
e was=20
> asking could help, you can find them from /proc/net/{netstat,snmp}...

That will also tell us if TCP discarded the packet due to
timestamps tests or similar.
