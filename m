From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] qed: Add iWARP support for unaligned
 MPA packets
Date: Mon, 09 Oct 2017 10:21:40 -0700 (PDT)
Message-ID: <20171009.102140.2175089236847138512.davem@davemloft.net>
References: <1507541874-18344-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507541874-18344-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Mon, 9 Oct 2017 12:37:42 +0300

> This patch series adds support for handling unaligned MPA packets.
> (FPDUs split over more than one tcp packet).
> When FW detects a packet is unaligned it fowards the packet to 
> the driver via a light l2 dedicated connection. The driver then 
> stores this packet until the remainder of the packet is received.
> Once the driver reconstructs the full FPDU, it sends it down
> to fw via the ll2 connection. Driver also breaks down any packed
> PDUs into separate packets for FW. 
> 
> Patches 1-6 are all slight modifications to ll2 to support additional
> requirements for the unaligned MPA ll2 client.
> 
> Patch 7 opens the additional ll2 connection for iWARP.
> Patches 8-12 contain the algorithm for aligning packets.
> 
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Series applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
