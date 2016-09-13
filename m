From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [net-next PATCH 00/11] iw_cxgb4,cxgbit: remove duplicate code
Date: Tue, 13 Sep 2016 15:18:42 -0500
Message-ID: <022b01d20dfc$05864150$1092c3f0$@opengridcomputing.com>
References: <cover.1473781521.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <target-devel@vger.kernel.org>, <nab@linux-iscsi.org>,
        <dledford@redhat.com>, <gerlitz.or@gmail.com>,
        <indranil@chelsio.com>
To: "'Varun Prakash'" <varun@chelsio.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44812 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754740AbcIMUSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 16:18:40 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch series removes duplicate code from
> iw_cxgb4 and cxgbit by adding common function
> definitions in libcxgb.
> 
> Please review.
> 
> Thanks
> Varun
> 
> Varun Prakash (11):
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_get_4tuple()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route6()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_is_neg_adv()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_best_mtu()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_compute_wscale()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_tid_release()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_close_con_req()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_req()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_rpl()
>   libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_rx_data_ack()
> 
>  drivers/infiniband/hw/cxgb4/Kconfig               |   1 +
>  drivers/infiniband/hw/cxgb4/Makefile              |   1 +
>  drivers/infiniband/hw/cxgb4/cm.c                  | 288
++++++----------------
>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h            |   9 -
>  drivers/net/ethernet/chelsio/libcxgb/Makefile     |   4 +-
>  drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 149 +++++++++++
>  drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 160 ++++++++++++
>  drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 234 +++---------------
>  8 files changed, 428 insertions(+), 418 deletions(-)
>  create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
>  create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
> 

This series looks good.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>

Thanks Varun!

Steve
