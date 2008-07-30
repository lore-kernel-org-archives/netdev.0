From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 17:24:26 -0500
Message-ID: <1217456666.18911.145.camel@calx>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	 <20080730.143532.124324888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:35376 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYG3W06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 18:26:58 -0400
In-Reply-To: <20080730.143532.124324888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-07-30 at 14:35 -0700, David Miller wrote:
> This change means you can't configure nearly all of the features on
> your ethernet card.  You can't even configure the link parameters
> without ethtool support.

Which is big fat don't-care for the vast majority of users. =EF=BB=BF=EF=
=BB=BFVarious
popular distros don't even install the tool by default.

Embedded devices care even less. You'd be fairly hard-pressed to find,
say, a BluRay player that lets you set the link duplex and checksum
offloading somewhere deep deep down in the setup menu. And good luck
trying to do that -over the wire- to a headless device. Unless the
device is a serious router, you're -never- going to see anyone go to th=
e
trouble of exporting such functionality.

--=20
Mathematics is the supreme nostalgia of our time.

