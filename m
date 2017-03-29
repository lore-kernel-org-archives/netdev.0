From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: refactor interrupt moderation code
Date: Tue, 28 Mar 2017 22:22:14 -0700 (PDT)
Message-ID: <20170328.222214.1756373038371091205.davem@davemloft.net>
References: <20170328191406.GA1027@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752410AbdC2FWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:22:16 -0400
In-Reply-To: <20170328191406.GA1027@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 28 Mar 2017 12:14:06 -0700

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Refactor interrupt moderation code for flexibility because parameters are
> different for 10G and 25G cards.  Currently parameters (for 10G only) come
> from macros compiled-in to the PF and VF drivers; fix it so that parameters
> suitable for the card (10G or 25G) come from the NIC firmware via response
> to a command.
> 
> Also bump up driver version to 1.5.1 to match newer NIC firmware version.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied.
