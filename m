From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: rework korina_rx() for use with napi
Date: Wed, 14 Jan 2009 21:49:06 -0800 (PST)
Message-ID: <20090114.214906.193008558.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955461-11187-1-git-send-email-n0-1@freewrt.org>
	<200901141858.50275.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754420AbZAOFtF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:49:05 -0500
In-Reply-To: <200901141858.50275.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 18:58:50 +0100

> Le Wednesday 14 January 2009 18:51:01 Phil Sutter, vous avez =E9crit=A0=
:
> > This function needs an early exit condition to function properly, o=
r
> > else caller assumes napi workload wasn't enough to handle all recei=
ved
> > packets and korina_rx is called again (and again and again and ...)=
=2E
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
