From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: set sriov_totalvfs correctly
Date: Wed, 02 Aug 2017 16:51:56 -0700 (PDT)
Message-ID: <20170802.165156.848203484625013901.davem@davemloft.net>
References: <20170801220507.GA1357@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdHBXv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:51:57 -0400
In-Reply-To: <20170801220507.GA1357@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 1 Aug 2017 15:05:07 -0700

> From: Derek Chickles <derek.chickles@cavium.com>
> 
> The file /sys/devices/pci000.../sriov_totalvfs is showing a wrong value.
> Fix it by calling pci_sriov_set_totalvfs() to set the total number of VFs
> available after calculations for the number of PF and VF queues are made.
> 
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
