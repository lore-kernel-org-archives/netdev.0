From: Kalle Valo <kalle.valo@nokia.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 13:22:41 +0300
Message-ID: <873alqwdxq.fsf@nokia.com>
References: <1217459102.18911.182.camel@calx>
	<20080730.162153.124485443.davem@davemloft.net>
	<1217466609.18911.227.camel@calx>
	<20080730.182309.35986438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, akpm@linux-foundation.org, jeff@garzik.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:65002 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbYGaKZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:25:18 -0400
In-Reply-To: <20080730.182309.35986438.davem@davemloft.net> (ext David Miller's message of "Wed\, 30 Jul 2008 18\:23\:09 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Looking at various kernel boot message logs of N800's posted online,
> it seems to have netfilter enabled.  The ip_tables module does get
> loaded.

That's true, netfilter is enabled on N800/N810. We use it to send idle
traffic timeout events to user space.

-- 
Kalle Valo
