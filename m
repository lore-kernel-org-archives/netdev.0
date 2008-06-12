From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/macsonic.c: make functions static
Date: Wed, 11 Jun 2008 22:50:58 -0400
Message-ID: <48508F12.6020706@pobox.com>
References: <20080609222347.GR1987@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40496 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311AbYFLCvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:51:00 -0400
In-Reply-To: <20080609222347.GR1987@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch makes the following needlessly global functions static:
> - macsonic_init()
> - mac_onboard_sonic_ethernet_addr()
> - mac_onboard_sonic_probe()
> - mac_nubus_sonic_ethernet_addr()
> - macsonic_ident()
> - mac_nubus_sonic_probe()
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/macsonic.c |   19 ++++++++-----------
>  1 file changed, 8 insertions(+), 11 deletions(-)

applied five of these



