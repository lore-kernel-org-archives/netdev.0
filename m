From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sis190: new PHY support
Date: Thu, 29 Mar 2007 08:27:06 -0400
Message-ID: <460BB09A.3000605@garzik.org>
References: <20070328221850.GA10571@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Gibbons <paul@pkami.e7even.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52544 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbXC2M1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:27:08 -0400
In-Reply-To: <20070328221850.GA10571@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Reported to work on the WinFast 761GXK8MB-RS motherboard.
> 
> Plain 10/100 Mbps.
> 
> Signed-off-by: Paul Gibbons <paul@pkami.e7even.com>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/sis190.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index b08508b..34463ce 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -324,6 +324,7 @@ static struct mii_chip_info {
>  	u32 feature;
>  } mii_chip_table[] = {
>  	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
> +	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },
>  	{ "Agere PHY ET1101B",    { 0x0282, 0xf010 }, LAN, 0 },
>  	{ "Marvell PHY 88E1111",  { 0x0141, 0x0cc0 }, LAN, F_PHY_88E1111 },
>  	{ "Realtek PHY RTL8201",  { 0x0000, 0x8200 }, LAN, 0 },

applied

