From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH net-next-2.6] netdev: tilepro: Use is_multicast_ether_addr
 helper
Date: Wed, 12 Jan 2011 12:49:03 -0500
Message-ID: <4D2DE98F.1090705@tilera.com>
References: <1294824713-10644-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([206.83.70.70]:36218 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1ALRya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 12:54:30 -0500
In-Reply-To: <1294824713-10644-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/2011 4:31 AM, Tobias Klauser wrote:
> Use is_multicast_ether_addr from linux/etherdevice.h instead of a custom
> macro. Also remove the broadcast address check, as it is considered a
> multicast address too.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/tile/tilepro.c |   10 +---------
>  1 files changed, 1 insertions(+), 9 deletions(-)

Thanks, I've taken this into the Tilera tree!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

