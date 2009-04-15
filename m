From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] FEC driver: patches for -next
Date: Wed, 15 Apr 2009 22:12:05 +1000
Message-ID: <49E5CF15.80601@snapgear.com>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:59670 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757151AbZDOMMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 08:12:09 -0400
In-Reply-To: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Sascha,

Sascha Hauer wrote:
> These patches aim to modernize the FEC ethernet driver.
> Greg, can you please confirm that the ifdef in patch 01/12 is indeed unused?

It is used for the CONFIG_M5272 case. The offsets to some registers
are slightly different for the version of the FEC hardware in that
SoC CPU.

Regards
Greg


> The following changes since commit 0882e8dd3aad33eca41696d463bb896e6c8817eb:
>   Linus Torvalds (1):
>         Linux 2.6.30-rc2
> 
> are available in the git repository at:
> 
>   git://git.pengutronix.de/git/sha/linux-2.6.git fec
> 
> Sascha Hauer (12):
>       fec: remove unused ifdef
>       fec: switch to writel/readl
>       fec: do not typedef struct types
>       fec: remove unnecessary cast
>       fec: Codingstyle cleanups
>       fec: refactor set_multicast_list() to make it more readable
>       fec: refactor init function
>       fec: align receive packets
>       fec: remove debugging printks
>       fec: switch to net_device_ops
>       FEC Buffer rework
>       fec: call fec_restart() in fec_open()
> 
>  drivers/net/fec.c |  897 ++++++++++++++++++++++-------------------------------
>  drivers/net/fec.h |  112 ++-----
>  2 files changed, 402 insertions(+), 607 deletions(-)
> 


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
