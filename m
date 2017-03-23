From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: allocate RX buffers in OOM
 conditions in PF and VF
Date: Wed, 22 Mar 2017 19:37:26 -0700 (PDT)
Message-ID: <20170322.193726.2099479598078112953.davem@davemloft.net>
References: <20170322183113.GA1035@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbdCWCh2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:37:28 -0400
In-Reply-To: <20170322183113.GA1035@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 22 Mar 2017 11:31:13 -0700

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Add workqueue that is periodically run to try to allocate RX buffers in OOM
> conditions in PF and VF.
> 
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, but I'm really not so sure you want to poll these queue states
4 times a second all the time.

Why don't you trigger the workqueue when you actually get an allocation
failure?
