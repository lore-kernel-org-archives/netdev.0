From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] r8169: revert bogus BMCR reset
Date: Fri, 09 Mar 2007 11:52:36 -0500
Message-ID: <45F190D4.3070009@garzik.org>
References: <20070308225954.GA27354@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roman Jarosz <kedgedev@centrum.cz>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Edward Hsu <edward_hsu@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57830 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767406AbXCIQwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:52:39 -0500
In-Reply-To: <20070308225954.GA27354@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Added during bf793295e1090af84972750898bf8470df5e5419
> 
> The current code requests a reset but prohibits autoneg, 1000 Mb/s,
> 100 Mb/s and full duplex. The 8168 does not like it at all.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied 1-2


