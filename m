From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix tx completions in napi poll
Date: Wed, 22 Mar 2017 19:37:33 -0700 (PDT)
Message-ID: <20170322.193733.238416511372843277.davem@davemloft.net>
References: <20170322185449.GA1072@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753995AbdCWChf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:37:35 -0400
In-Reply-To: <20170322185449.GA1072@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 22 Mar 2017 11:54:50 -0700

> From: VSR Burru <veerasenareddy.burru@cavium.com>
> 
> If there are no egress packets pending, then don't look for tx completions
> in napi poll.  Also, fix broken tx queue wakeup logic.
> 
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied.
