From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 11/12] FEC Buffer rework
Date: Fri, 17 Apr 2009 12:12:09 +0200
Message-ID: <20090417101209.GN21747@pengutronix.de>
References: <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-11-git-send-email-s.hauer@pengutronix.de> <1239795145-27558-12-git-send-email-s.hauer@pengutronix.de> <49E854DE.2050302@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52167 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759562AbZDQKMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 06:12:10 -0400
Content-Disposition: inline
In-Reply-To: <49E854DE.2050302@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 08:07:26PM +1000, Greg Ungerer wrote:
>
> Hi Sascha,
>
> Sascha Hauer wrote:
>> Allocate buffers in fec_open and free them again in fec_close. This makes
>> it possible to use this driver as a module.
>>
>> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
>
> This is the only one that doesn't work for ColdFire. There is no
> dma_map_single() or dma_unmap_single() currently. I will fix that,
> so I am fine with this anyways.
>
> With all the other patches applied it still basically works on ColdFire
> (at least on initial testing on a 5208). I have seen a few spurious
> interrupts though with these changes applied, that didn't happen
> before. I will investigate further when get a few minutes.

Ok, thanks for testing

Regards,
  Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
