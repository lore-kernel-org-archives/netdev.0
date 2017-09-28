From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-next/hinic: Fix a case of Tx Queue is
 Stopped forever
Date: Thu, 28 Sep 2017 10:27:16 -0700 (PDT)
Message-ID: <20170928.102716.1596635867248168695.davem@davemloft.net>
References: <1506449493-83395-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: aviad.krawczyk@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506449493-83395-1-git-send-email-aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Date: Wed, 27 Sep 2017 02:11:33 +0800

> Fix the following scenario:
> 1. tx_free_poll is running on cpu X
> 2. xmit function is running on cpu Y and fails to get sq wqe
> 3. tx_free_poll frees wqes on cpu X and checks the queue is not stopped
> 4. xmit function stops the queue after failed to get sq wqe
> 5. The queue is stopped forever
> 
> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>

Applied.
