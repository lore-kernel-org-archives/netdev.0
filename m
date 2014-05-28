From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 1/2] net: tile:  Remove unnecessary memset of netdev private
 data
Date: Wed, 28 May 2014 15:35:22 -0400
Message-ID: <53863A7A.5020407@tilera.com>
References: <1401192231-26203-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:27303 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaE1TfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 15:35:24 -0400
In-Reply-To: <1401192231-26203-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/2014 8:03 AM, Tobias Klauser wrote:
> The memory for private data is allocated using kzalloc/vzalloc in
> alloc_netdev_mqs, thus there is no need to zero it again in the driver.
>
> Signed-off-by: Tobias Klauser<tklauser@distanz.ch>
> ---
>   drivers/net/ethernet/tile/tilegx.c |    1 -
>   1 file changed, 1 deletion(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
