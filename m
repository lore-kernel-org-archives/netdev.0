From: David Miller <davem@davemloft.net>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 01:56:56 -0700 (PDT)
Message-ID: <20070729.015656.41635835.davem@davemloft.net>
References: <46AC2CBE.5010500@netbauds.net>
	<20070729064511.GA18718@1wt.eu>
	<Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: w@1wt.eu, darryl-mailinglists@netbauds.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760651AbXG2I44 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 04:56:56 -0400
In-Reply-To: <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 29 Jul 2007 11:26:00 +0300 (EEST)

> Is this reproducable? Can you somehow verify that the packets CLIENT =
is=20
> sending are indeed received by the SERVER...?

One possibility is drops due to checksum errors on the receiver, this
tends to pop up from time to time, let's see some SNMP statistics.
