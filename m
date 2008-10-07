From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET-NEXT PATCH 1/6] ixgbe: this patch adds support for DCB to the kernel and ixgbe driver
Date: Mon, 6 Oct 2008 20:14:05 -0700
Message-ID: <9929d2390810062014s139b3eb7x1617632ce327dbbf@mail.gmail.com>
References: <20081007030540.782.28987.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:13661 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616AbYJGDOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 23:14:09 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1417379wri.5
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2008 20:14:06 -0700 (PDT)
In-Reply-To: <20081007030540.782.28987.stgit@gitlost.lost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2008 at 8:05 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
>  drivers/net/ixgbe/Makefile          |    3
>  drivers/net/ixgbe/ixgbe.h           |   26 +
>  drivers/net/ixgbe/ixgbe_dcb.c       |  332 +++++++++++++++++
>  drivers/net/ixgbe/ixgbe_dcb.h       |  158 ++++++++
>  drivers/net/ixgbe/ixgbe_dcb_82598.c |  398 ++++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_dcb_82598.h |   94 +++++
>  drivers/net/ixgbe/ixgbe_dcb_nl.c    |  352 ++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_ethtool.c   |   37 ++
>  drivers/net/ixgbe/ixgbe_main.c      |  189 +++++++++-
>  include/linux/dcbnl.h               |  230 ++++++++++++
>  include/linux/netdevice.h           |    8
>  include/linux/rtnetlink.h           |    5
>  include/net/dcbnl.h                 |   44 ++
>  net/Kconfig                         |    1
>  net/Makefile                        |    3
>  net/dcb/Kconfig                     |   12 +
>  net/dcb/Makefile                    |    1
>  net/dcb/dcbnl.c                     |  682 +++++++++++++++++++++++++++++++++++
>  18 files changed, 2555 insertions(+), 20 deletions(-)
>  create mode 100644 drivers/net/ixgbe/ixgbe_dcb.c
>  create mode 100644 drivers/net/ixgbe/ixgbe_dcb.h
>  create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82598.c
>  create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82598.h
>  create mode 100644 drivers/net/ixgbe/ixgbe_dcb_nl.c
>  create mode 100644 include/linux/dcbnl.h
>  create mode 100644 include/net/dcbnl.h
>  create mode 100644 net/dcb/Kconfig
>  create mode 100644 net/dcb/Makefile
>  create mode 100644 net/dcb/dcbnl.c
>

Sorry I got PJ's email incorrect the first time, resent with PJ's correct email.


-- 
Cheers,
Jeff
