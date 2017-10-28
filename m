From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] liquidio: fix kernel panic in VF driver
Date: Sat, 28 Oct 2017 18:53:35 +0900 (KST)
Message-ID: <20171028.185335.2096411268542820879.davem@redhat.com>
References: <20171026234636.GA18898@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750882AbdJ1Jxt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 05:53:49 -0400
In-Reply-To: <20171026234636.GA18898@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 26 Oct 2017 16:46:36 -0700

> Doing ifconfig down on VF driver in the middle of receiving line rate
> traffic causes a kernel panic:
 ...
> Reason is:  in the function assigned to net_device_ops->ndo_stop, the steps
> for bringing down the interface are done in the wrong order.  The step that
> notifies the NIC firmware to stop forwarding packets to host is done too
> late.  Fix it by moving that step to the beginning.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>

Applied, thanks.
