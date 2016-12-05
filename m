From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/28] bnxt_en: Add bnxt_set_max_func_irqs().
Date: Mon, 05 Dec 2016 11:47:04 -0500 (EST)
Message-ID: <20161205.114704.1700305660817315475.davem@davemloft.net>
References: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
        <1480919912-1079-2-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        michael.chan@broadcom.com, netdev@vger.kernel.org
To: selvin.xavier@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbcLEQrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:47:09 -0500
In-Reply-To: <1480919912-1079-2-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It really doesn't make any sense to only send 7 out of 28 of these
patches to the networking list.

In fact I would say that you need to split this series into two
components.

One that goes into the networking tree, and once that's accepted you
can submit the IB parts to that subsystem's maintainer.
