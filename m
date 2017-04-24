From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] qlcnic: fix unchecked return value
Date: Mon, 24 Apr 2017 16:11:16 -0400 (EDT)
Message-ID: <20170424.161116.271050954695792950.davem@davemloft.net>
References: <1492949044-23580-1-git-send-email-bianpan201602@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bianpan2016@163.com
To: bianpan201602@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1174089AbdDXULS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:11:18 -0400
In-Reply-To: <1492949044-23580-1-git-send-email-bianpan201602@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aFrom: Pan Bian <bianpan201602@163.com>
Date: Sun, 23 Apr 2017 20:04:04 +0800

> From: Pan Bian <bianpan2016@163.com>
> 
> Function pci_find_ext_capability() may return 0, which is an invalid
> address. In function qlcnic_sriov_virtid_fn(), its return value is used
> without validation. This may result in invalid memory access bugs. This
> patch fixes the bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Applied.
