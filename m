From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH net-next  00/18] liquidio support for new device cn23xx
Date: Wed, 03 Aug 2016 13:51:46 -0700
Message-ID: <57A25962.4030507@gmail.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35957 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757411AbcHCUvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 16:51:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so15240830pfg.3
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 13:51:49 -0700 (PDT)
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2016 11:55 AM, Raghu Vatsavayi wrote:
> Dave,
>
> Please consider following patches for support of new device
> CN23XX in liquidio family of adapters. Patches may have to
> be applied in following order as some of the patches depend
> on earlier patches.
>
> Thanks
> Raghu Vatsavayi.
>
> Raghu Vatsavayi (18):
>    0001-liquidio-support-for-new-device-cn23xx.patch
>    0002-liquidio-support-for-new-device-cn23xx.patch
>    0003-liquidio-support-for-new-device-cn23xx.patch
>    0004-liquidio-support-for-new-device-cn23xx.patch
>    0005-liquidio-support-for-new-device-cn23xx.patch
>    0006-liquidio-support-for-new-device-cn23xx.patch
>    0007-liquidio-support-for-new-device-cn23xx.patch
>    0008-liquidio-support-for-new-device-cn23xx.patch
>    0009-liquidio-support-for-new-device-cn23xx.patch
>    0010-liquidio-support-for-new-device-cn23xx.patch
>    0011-liquidio-support-for-new-device-cn23xx.patch
>    0012-liquidio-support-for-new-device-cn23xx.patch
>    0013-liquidio-support-for-new-device-cn23xx.patch
>    0014-liquidio-support-for-new-device-cn23xx.patch
>    0015-liquidio-support-for-new-device-cn23xx.patch
>    0016-liquidio-support-for-new-device-cn23xx.patch
>    0017-liquidio-support-for-new-device-cn23xx.patch
>    0018-liquidio-support-for-new-device-cn23xx.patch

All 18 patches have identical subject lines, that is not correct.

Also each changelog begins with the identical text "This patch ...", we 
know it is a patch, so saying that is redundant.  Just say what the 
patch does, something like "Add support for ..."


>
>   drivers/net/ethernet/cavium/Kconfig                |    4 +-
>   drivers/net/ethernet/cavium/liquidio/Makefile      |   24 +-
>   .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 1274 ++++++++++++++++++++
>   .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   63 +
>   .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  |  602 +++++++++
>   .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   12 +-
>   .../net/ethernet/cavium/liquidio/cn66xx_device.h   |    4 +-
>   drivers/net/ethernet/cavium/liquidio/lio_core.c    |  271 +++++
>   drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  504 +++++++-
>   drivers/net/ethernet/cavium/liquidio/lio_main.c    | 1143 +++++++++++-------
>   .../net/ethernet/cavium/liquidio/liquidio_common.h |   29 +-
>   .../net/ethernet/cavium/liquidio/octeon_config.h   |   59 +-
>   .../net/ethernet/cavium/liquidio/octeon_console.c  |  116 +-
>   .../net/ethernet/cavium/liquidio/octeon_device.c   |  352 ++++--
>   .../net/ethernet/cavium/liquidio/octeon_device.h   |  126 +-
>   drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   46 +-
>   drivers/net/ethernet/cavium/liquidio/octeon_droq.h |    2 +
>   drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |    2 +
>   drivers/net/ethernet/cavium/liquidio/octeon_main.h |   32 +-
>   .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |    1 -
>   .../net/ethernet/cavium/liquidio/octeon_network.h  |    6 +-
>   drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |   35 +-
>   drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |    2 +-
>   .../net/ethernet/cavium/liquidio/request_manager.c |  170 ++-
>   .../ethernet/cavium/liquidio/response_manager.c    |    9 +-
>   25 files changed, 4199 insertions(+), 689 deletions(-)
>   create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
>   create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
>   create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
>   create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_core.c
>
