From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: constify data and function pointer tables
Date: Wed, 30 Jan 2008 04:25:17 -0500
Message-ID: <47A0427D.7040301@garzik.org>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de> <Pine.LNX.4.64.0801222046170.5722@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60878 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbYA3JZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 04:25:20 -0500
In-Reply-To: <Pine.LNX.4.64.0801222046170.5722@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
> ---
>  drivers/net/bonding/bond_main.c         |    2 +-
>  drivers/net/hamradio/bpqether.c         |    2 +-
>  drivers/net/hamradio/scc.c              |    2 +-
>  drivers/net/hamradio/yam.c              |    2 +-
>  drivers/net/ibmveth.c                   |    2 +-
>  drivers/net/pppoe.c                     |    2 +-
>  drivers/net/pppol2tp.c                  |    4 ++--
>  drivers/net/wireless/libertas/debugfs.c |   14 +++++++-------
>  drivers/net/wireless/strip.c            |    2 +-
>  9 files changed, 16 insertions(+), 16 deletions(-)

ACK -- but you should collect linville's ack of the wireless stuff too 
(even though the patch is simple and obvious)


