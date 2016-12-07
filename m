From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/7] bnxt_en: Add interface to support RDMA
 driver.
Date: Wed, 07 Dec 2016 10:59:42 -0500 (EST)
Message-ID: <20161207.105942.1110054643013714151.davem@davemloft.net>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Wed,  7 Dec 2016 00:26:14 -0500

> This series adds an interface to support a brand new RDMA driver bnxt_re.
> The first step is to re-arrange some code so that pci_enable_msix() can
> be called during pci probe.  The purpose is to allow the RDMA driver to
> initialize and stay initialized whether the netdev is up or down.
> 
> Then we make some changes to VF resource allocation so that there is
> enough resources to support RDMA.
> 
> Finally the last patch adds a simple interface to allow the RDMA driver to
> probe and register itself with any bnxt_en devices that support RDMA.
> Once registered, the RDMA driver can request MSIX, send fw messages, and
> receive some notifications.
> 
> v2: Fixed kbuild test robot warnings.
> 
> David, please consider this series for net-next.  Thanks.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
