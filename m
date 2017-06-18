From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Sun, 18 Jun 2017 06:14:43 -0700
Message-ID: <20170618131443.GA27458@infradead.org>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Michal.Kalderon@cavium.com, linux-rdma@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:53678 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdFRNOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 09:14:46 -0400
Content-Disposition: inline
In-Reply-To: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 18, 2017 at 02:50:28PM +0300, Yuval Mintz wrote:
> This series focuses on RDMA in general with emphasis on required changes
> toward adding iWARP support. The vast majority of the changes introduced
> are in qed/qede, with a couple of small changes to qedr
> [mentioned below].

Btw, can you explain us how you are going to expose RoCE vs iWarp?
Is it going to be a per-port setting?  Are you going to use different
ib_device structures or do you plan to differenciate at another level?
