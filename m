From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] FEC driver: patches for -next
Date: Wed, 15 Apr 2009 14:55:36 +0200
Message-ID: <20090415125536.GV14383@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de> <49E5CF15.80601@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37966 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082AbZDOMzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 08:55:37 -0400
Content-Disposition: inline
In-Reply-To: <49E5CF15.80601@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 10:12:05PM +1000, Greg Ungerer wrote:
>
> Hi Sascha,
>
> Sascha Hauer wrote:
>> These patches aim to modernize the FEC ethernet driver.
>> Greg, can you please confirm that the ifdef in patch 01/12 is indeed unused?
>
> It is used for the CONFIG_M5272 case. The offsets to some registers
> are slightly different for the version of the FEC hardware in that
> SoC CPU.

Ok, then I'll skip the first patch and update the second one
accordingly.

Regards
  Sascha

>
> Regards
> Greg
>
>
>> The following changes since commit 0882e8dd3aad33eca41696d463bb896e6c8817eb:
>>   Linus Torvalds (1):
>>         Linux 2.6.30-rc2
>>
>> are available in the git repository at:
>>
>>   git://git.pengutronix.de/git/sha/linux-2.6.git fec
>>
>> Sascha Hauer (12):
>>       fec: remove unused ifdef
>>       fec: switch to writel/readl
>>       fec: do not typedef struct types
>>       fec: remove unnecessary cast
>>       fec: Codingstyle cleanups
>>       fec: refactor set_multicast_list() to make it more readable
>>       fec: refactor init function
>>       fec: align receive packets
>>       fec: remove debugging printks
>>       fec: switch to net_device_ops
>>       FEC Buffer rework
>>       fec: call fec_restart() in fec_open()
>>
>>  drivers/net/fec.c |  897 ++++++++++++++++++++++-------------------------------
>>  drivers/net/fec.h |  112 ++-----
>>  2 files changed, 402 insertions(+), 607 deletions(-)
>>
>
>
> -- 
> ------------------------------------------------------------------------
> Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
> SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
> 825 Stanley St,                             FAX:         +61 7 3891 3630
> Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
>

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
