From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix PF falsely indicating success
 at setting MAC address of a nonexistent VF
Date: Wed, 17 May 2017 14:50:36 -0400 (EDT)
Message-ID: <20170517.145036.2098131861729499280.davem@davemloft.net>
References: <20170516182800.GA1067@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752038AbdEQSui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:50:38 -0400
In-Reply-To: <20170516182800.GA1067@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 16 May 2017 11:28:00 -0700

> In the function assigned to .ndo_set_vf_mac, check the validity of the
> vfidx argument before proceeding to tell the firmware to set the VF MAC
> address.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied.
